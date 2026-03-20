const fs = require('fs');
const path = require('path');
const axios = require('axios');

const medicalDataPath = path.join(__dirname, 'medical_data.json');

function get_emergency_protocol(type) {
    console.log(`Tool calling: get_emergency_protocol(${type})`);
    const data = JSON.parse(fs.readFileSync(medicalDataPath, 'utf8'));
    
    // Search protocols by key or by voice_triggers
    const protocolKey = Object.keys(data.protocols).find(key => 
        key.toLowerCase().includes(type.toLowerCase()) || 
        type.toLowerCase().includes(key.toLowerCase()) ||
        data.protocols[key].voice_triggers?.some(t => t.toLowerCase().includes(type.toLowerCase()) || type.toLowerCase().includes(t.toLowerCase()))
    );
    
    const protocol = protocolKey ? data.protocols[protocolKey] : null;
    
    if (protocol) {
        return {
            type: protocolKey,
            steps: protocol.steps,
            metronome_bpm: protocol.metronome_bpm
        };
    }

    return { error: "Protocol not found. Advise staying calm and checking breathing." };
}

async function find_nearest_hospital(lat, long) {
    console.log(`Tool calling: find_nearest_hospital(${lat}, ${long})`);
    const apiKey = process.env.GOOGLE_PLACES_API_KEY;
    
    if (!apiKey) {
        // Mock data if no API key is provided
        return [
            { name: "City General Hospital", address: "123 Health Blvd", distance: "1.2 miles", eta: "4 mins" },
            { name: "St. Jude Emergency Center", address: "456 Safety Way", distance: "2.5 miles", eta: "8 mins" }
        ];
    }

    try {
        const response = await axios.get(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${long}&radius=5000&type=hospital&key=${apiKey}`);
        return response.data.results.slice(0, 3).map(h => ({
            name: h.name,
            address: h.vicinity,
            rating: h.rating
        }));
    } catch (error) {
        console.error("Error calling Places API:", error.message);
        return { error: "Could not fetch nearby hospitals." };
    }
}

async function notify_ems(payload) {
    console.log("Tool calling: notify_ems", payload);
    // Mocking an EMS dispatch request
    return {
        status: "DISPATCHED",
        incident_id: "EMS-" + Math.random().toString(36).substr(2, 9).toUpperCase(),
        eta: "5-7 mins",
        message: "Emergency services have been notified and are en route."
    };
}

module.exports = {
    get_emergency_protocol,
    find_nearest_hospital,
    notify_ems
};
