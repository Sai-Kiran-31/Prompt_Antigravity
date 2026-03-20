require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { VertexAI } = require('@google-cloud/vertexai');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { Logging } = require('@google-cloud/logging');
const { get_emergency_protocol, find_nearest_hospital, notify_ems } = require('./tools');

const app = express();
app.use(cors());
app.use(express.json());
const port = process.env.PORT || 8081;

// Configuration
const project = process.env.GCP_PROJECT_ID || 'prompt-antigravity';
const apiKey = process.env.GOOGLE_API_KEY;

// Logging setup - only use Cloud Logging when GCP credentials are available
const useCloudLogging = process.env.GOOGLE_APPLICATION_CREDENTIALS || process.env.K_SERVICE; // K_SERVICE is set on Cloud Run
let log;

if (useCloudLogging) {
    const logging = new Logging({ projectId: project });
    log = logging.log('aegis-copilot-audit');
    console.log("Cloud Logging enabled.");
} else {
    console.log("Cloud Logging disabled (no GCP credentials). Using console logging.");
}

async function writeLog(entry) {
    console.log("[AUDIT]", JSON.stringify(entry));
    if (log) {
        try {
            const metadata = { resource: { type: 'global' } };
            const logEntry = log.entry(metadata, entry);
            await log.write(logEntry);
        } catch (err) {
            // Silently ignore Cloud Logging failures locally
        }
    }
}


// Model Initialization
let generativeModel;

if (apiKey) {
    console.log("Using Google AI SDK with API Key.");
    const genAI = new GoogleGenerativeAI(apiKey);
    generativeModel = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
} else {
    console.log("Using Vertex AI SDK with GCP Project ID:", project);
    const vertexAI = new VertexAI({ project: project, location: 'us-central1' });
    generativeModel = vertexAI.getGenerativeModel({
        model: 'gemini-1.5-flash',
        generation_config: { response_mime_type: 'application/json' }
    });
}


const tools = [
    {
        function_declarations: [
            {
                name: "get_emergency_protocol",
                description: "Fetches emergency medical steps for a given type of medical emergency (e.g., CPR, Choking, Bleeding).",
                parameters: {
                    type: "object",
                    properties: {
                        type: { type: "string", description: "The type of emergency" }
                    },
                    required: ["type"]
                }
            },
            {
                name: "find_nearest_hospital",
                description: "Finds the nearest hospital based on latitude and longitude coordinates.",
                parameters: {
                    type: "object",
                    properties: {
                        lat: { type: "number", description: "Latitude" },
                        long: { type: "number", description: "Longitude" }
                    },
                    required: ["lat", "long"]
                }
            },
            {
                name: "notify_ems",
                description: "Mocks a request to emergency medical services (EMS) dispatch center.",
                parameters: {
                    type: "object",
                    properties: {
                        payload: { type: "object", description: "Details about the emergency" }
                    },
                    required: ["payload"]
                }
            }
        ]
    }
];

app.post('/api/agent', async (req, res) => {
    const { transcript, location: userLocation } = req.body;

    if (!transcript) {
        return res.status(400).json({ error: "Transcript is required." });
    }

    console.log("Processing transcript:", transcript);

    // First, get the emergency protocol locally
    const protocol = get_emergency_protocol(transcript);
    console.log("Local protocol lookup:", protocol);

    const prompt = `
        You are an Emergency Copilot AI. A user has provided a messy audio transcript or text describing an emergency.
        Analyze the situation and determine the necessary emergency action.
        
        User location: ${JSON.stringify(userLocation || "Unknown")}.
        
        Here is relevant medical protocol data that was looked up: ${JSON.stringify(protocol)}

        Based on this information, return ONLY a valid JSON object (no markdown, no code fences) with this exact structure:
        {
            "action": "ACTION_TYPE (e.g., SHOW_CPR, SHOW_CHOKING, SHOW_BLEEDING, CALL_911, FIND_HOSPITAL)",
            "priority": "CRITICAL or HIGH or MEDIUM",
            "instructions": ["step 1", "step 2"],
            "metronome_bpm": 110,
            "reasoning": "Brief explanation",
            "hospital_eta": "4 mins",
            "ems_status": "DISPATCHED"
        }

        Transcript: "${transcript}"
    `;

    try {
        await writeLog({
            event: 'TRANSCRIPT_RECEIVED',
            transcript,
            location: userLocation,
            timestamp: new Date().toISOString()
        });

        let responseText;

        if (apiKey) {
            // Google AI SDK path
            const result = await generativeModel.generateContent(prompt);
            const response = result.response;
            responseText = response.text();
        } else {
            // Vertex AI SDK path
            const chat = generativeModel.startChat({ tools });
            let result = await chat.sendMessage(prompt);
            let response = result.response;

            let call = response.candidates[0].content.parts.find(p => p.functionCall);
            if (call) {
                const { name, args } = call.functionCall;
                await writeLog({ event: 'TOOL_CALL', name, args });
                let toolResult;
                if (name === "get_emergency_protocol") {
                    toolResult = get_emergency_protocol(args.type);
                } else if (name === "find_nearest_hospital") {
                    toolResult = await find_nearest_hospital(args.lat, args.long);
                } else if (name === "notify_ems") {
                    toolResult = await notify_ems(args.payload);
                }
                result = await chat.sendMessage([{
                    functionResponse: { name, response: { content: toolResult } }
                }]);
                response = result.response;
            }
            responseText = response.candidates[0].content.parts[0].text;
        }

        console.log("Raw AI response:", responseText);

        // Clean up response - remove markdown fences if present
        let cleanText = responseText.trim();
        if (cleanText.startsWith('```')) {
            cleanText = cleanText.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '');
        }

        const parsedResponse = JSON.parse(cleanText);

        await writeLog({
            event: 'MODEL_RESPONSE',
            response: parsedResponse,
            timestamp: new Date().toISOString()
        });

        res.json(parsedResponse);

    } catch (error) {
        console.error("AI Agent Error:", error.message || error);
        await writeLog({ event: 'ERROR', error: error.message });
        
        // Fallback: if the AI fails, still return protocol-based response
        if (protocol && !protocol.error) {
            console.log("Using fallback protocol response.");
            const fallback = {
                action: "SHOW_" + (protocol.type || "PROTOCOL").toUpperCase().replace(/\s+/g, '_'),
                priority: "HIGH",
                instructions: protocol.steps || ["Stay calm", "Call emergency services"],
                metronome_bpm: protocol.metronome_bpm || null,
                reasoning: "AI unavailable, using local protocol lookup.",
                hospital_eta: "Unknown",
                ems_status: "NOT_NOTIFIED"
            };
            return res.json(fallback);
        }
        
        res.status(500).json({ error: "Failed to process emergency request." });
    }
});



app.listen(port, () => {
    console.log(`AI Agent server listening on port ${port}`);
});
