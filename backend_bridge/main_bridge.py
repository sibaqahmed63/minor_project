import asyncio
import json
import socket
import websockets

# Connected Flutter WebSocket clients
CONNECTED_CLIENTS = set()

# --- ENVIRONMENT-SPECIFIC AI ENGINES ---

def evaluate_agriculture_ai(metrics):
    moisture = metrics.get("soil_moisture", 0)
    temp = metrics.get("temperature", 0)
    ph = metrics.get("soil_ph", 6.5)
    n, p, k = metrics.get("nitrogen_ppm", 0), metrics.get("phosphorus_ppm", 0), metrics.get("potassium_ppm", 0)

    # Crop suitability decision engine
    recommended_crops = []
    if 30 <= moisture <= 50 and 20 <= temp <= 32:
        recommended_crops.append("Wheat")
        recommended_crops.append("Chickpeas")
    if moisture > 40 and temp > 25:
        recommended_crops.append("Maize")
    if not recommended_crops:
        recommended_crops.append("Barley (Drought Tolerant)")

    # Irrigation & Soil Health status
    if moisture < 25:
        irrigation_status = "CRITICAL: Immediate Irrigation Required"
    elif moisture > 55:
        irrigation_status = "WARNING: Soil Waterlogged - Pause Irrigation"
    else:
        irrigation_status = "OPTIMAL: Moisture Levels Balanced"

    return {
        "ai_crop_recommendations": recommended_crops,
        "ai_irrigation_status": irrigation_status,
        "npk_health": "Balanced" if n > 25 and p > 15 and k > 20 else "Deficient - Fertilization Needed"
    }

def evaluate_forest_ai(metrics):
    temp = metrics.get("temperature", 0)
    co2 = metrics.get("smoke_co2_ppm", 0)
    wind = metrics.get("wind_speed_kmh", 0)
    flame = metrics.get("flame_detected", False)

    # Fire Risk Index Calculation
    if flame or co2 > 850 or temp > 45:
        risk_level = "CRITICAL_WILDFIRE_ALERT"
        action = "Evacuate Zone & Dispatch Suppression Units Immediately!"
    elif temp > 35 and wind > 15:
        risk_level = "HIGH_FIRE_HAZARD"
        action = "High temperature & wind detected. Increase surveillance."
    else:
        risk_level = "NORMAL"
        action = "Forest canopy parameters stable."

    return {
        "ai_fire_risk_level": risk_level,
        "ai_action_required": action,
        "fwi_hazard_score": min(100, round((temp * 1.5) + (wind * 1.2) + (co2 / 20), 1))
    }

def evaluate_disaster_ai(metrics):
    flood = metrics.get("flood_level_cm", 0)
    seismic = metrics.get("seismic_vibration_g", 0)
    gas = metrics.get("gas_leak_ppm", 0)
    aqi = metrics.get("air_quality_index", 0)

    alerts = []
    if flood > 100:
        alerts.append("CRITICAL: Severe Flood Height")
    if seismic > 0.3:
        alerts.append("CRITICAL: High Seismic Activity")
    if gas > 200:
        alerts.append("HAZARD: Hazardous Gas Leak Detected")

    return {
        "ai_hazard_alerts": alerts if alerts else ["Zone Stable"],
        "ai_evacuation_recommended": flood > 120 or seismic > 0.35,
        "air_safety": "Unsafe for Civilians" if aqi > 200 or gas > 150 else "Safe"
    }

# --- PACKET PROCESSING & BROADCAST ---

def process_ns3_packet(raw_data):
    try:
        data = json.loads(raw_data)
        env = data.get("environment")
        metrics = data.get("metrics", {})

        # Route packet to the corresponding AI module
        if env == "agriculture":
            data["ai_analysis"] = evaluate_agriculture_ai(metrics)
        elif env == "forest":
            data["ai_analysis"] = evaluate_forest_ai(metrics)
        elif env == "disaster":
            data["ai_analysis"] = evaluate_disaster_ai(metrics)

        return data
    except json.JSONDecodeError:
        return None

# UDP Listener for NS-3 Engine
class NS3UdpProtocol(asyncio.DatagramProtocol):
    def datagram_received(self, data, addr):
        message = data.decode('utf-8')
        processed = process_ns3_packet(message)
        if processed:
            print(f"[NS-3 -> AI ENGINE] {processed['environment'].upper()} | AI: {processed['ai_analysis']}")
            # Broadcast enriched payload to Flutter
            asyncio.create_task(broadcast_to_flutter(json.dumps(processed)))

async def broadcast_to_flutter(payload):
    if CONNECTED_CLIENTS:
        await asyncio.gather(*[client.send(payload) for client in CONNECTED_CLIENTS])

# WebSocket Server Handler for Flutter
async def flutter_ws_handler(websocket):
    CONNECTED_CLIENTS.add(websocket)
    print(">>> Flutter App Connected!")
    try:
        async for message in websocket:
            # Handle incoming simulation commands from Flutter UI (e.g., node kill requests)
            print(f"[FLUTTER COMMAND]: {message}")
    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        CONNECTED_CLIENTS.remove(websocket)

async def main():
    loop = asyncio.get_running_loop()

    # 1. Start UDP Listener for NS-3 on Port 9000
    await loop.create_datagram_endpoint(
        lambda: NS3UdpProtocol(),
        local_addr=('127.0.0.1', 9000)
    )
    print("NS-3 UDP Listener active on port 9000")

    # 2. Start WebSocket Server for Flutter on Port 8765
    async with websockets.serve(flutter_ws_handler, "0.0.0.0", 8765):
        print("Flutter WebSocket Server running on ws://localhost:8765")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())