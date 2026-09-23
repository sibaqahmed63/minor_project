#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/mobility-module.h"
#include "ns3/internet-module.h"
#include "ns3/aodv-module.h"
#include "ns3/wifi-module.h"
#include "ns3/yans-wifi-helper.h"
#include "ns3/ipv4.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sstream>
#include <iomanip>
#include <cmath>

using namespace ns3;

double GetRandomDelta(double minDelta, double maxDelta) {
    double r = (double)rand() / RAND_MAX;
    return minDelta + r * (maxDelta - minDelta);
}

double Clamp(double val, double minVal, double maxVal) {
    if (val < minVal) return minVal;
    if (val > maxVal) return maxVal;
    return val;
}

int ClampInt(int val, int minVal, int maxVal) {
    if (val < minVal) return minVal;
    if (val > maxVal) return maxVal;
    return val;
}

// Domain Telemetry State Containers
struct AgriState {
    double temp = 26.5;
    double moisture = 45.0;
    double humidity = 55.0;
    double ph = 6.5;
    int n = 35;
    int p = 20;
    int k = 25;
} g_agriState;

struct ForestState {
    double temp = 24.0;
    double humidity = 50.0;
    double wind = 12.0;
    int co2 = 420;
} g_forestState;

struct DisasterState {
    double flood = 10.0;
    double seismic = 0.02;
    int aqi = 85;
    double gas = 12.0;
} g_disasterState;

void SendTelemetry(Ptr<Socket> socket, Ipv4Address destAddr, uint16_t port, std::string envType, std::string nodeId) {
    if (Simulator::Now().GetSeconds() >= 3600.0) return;

    std::stringstream ss;
    ss << "{"
       << "\"environment\":\"" << envType << "\","
       << "\"node\":\"" << nodeId << "\","
       << "\"timestamp\":" << Simulator::Now().GetSeconds() << ","
       << "\"metrics\":{";

    if (envType == "agriculture") {
        g_agriState.temp = Clamp(g_agriState.temp + GetRandomDelta(-0.3, 0.3), 18.0, 36.0);
        double dryingRate = (g_agriState.temp > 30.0) ? -0.4 : -0.1;
        g_agriState.moisture = Clamp(g_agriState.moisture + GetRandomDelta(dryingRate - 0.2, 0.2), 15.0, 65.0);
        g_agriState.humidity = Clamp(g_agriState.humidity + GetRandomDelta(-0.8, 0.8), 35.0, 80.0);
        g_agriState.ph = Clamp(g_agriState.ph + GetRandomDelta(-0.02, 0.02), 6.0, 7.5);
        g_agriState.n = ClampInt(g_agriState.n + (rand() % 3 - 1), 20, 50);
        g_agriState.p = ClampInt(g_agriState.p + (rand() % 3 - 1), 10, 35);
        g_agriState.k = ClampInt(g_agriState.k + (rand() % 3 - 1), 15, 40);

        ss << std::fixed << std::setprecision(1)
           << "\"temperature\":" << g_agriState.temp << ","
           << "\"soil_moisture\":" << g_agriState.moisture << ","
           << "\"humidity\":" << g_agriState.humidity << ","
           << "\"soil_ph\":" << std::setprecision(2) << g_agriState.ph << ","
           << "\"nitrogen_ppm\":" << g_agriState.n << ","
           << "\"phosphorus_ppm\":" << g_agriState.p << ","
           << "\"potassium_ppm\":" << g_agriState.k;
    }
    else if (envType == "forest") {
        g_forestState.temp = Clamp(g_forestState.temp + GetRandomDelta(-0.2, 0.3), 18.0, 42.0);
        g_forestState.humidity = Clamp(g_forestState.humidity + GetRandomDelta(-0.6, 0.6), 20.0, 80.0);
        g_forestState.wind = Clamp(g_forestState.wind + GetRandomDelta(-0.8, 0.8), 2.0, 35.0);
        g_forestState.co2 = ClampInt(g_forestState.co2 + (rand() % 9 - 4), 390, 700);
        bool flameDetected = (g_forestState.temp > 45.0 || g_forestState.co2 > 850);

        ss << std::fixed << std::setprecision(1)
           << "\"temperature\":" << g_forestState.temp << ","
           << "\"humidity\":" << g_forestState.humidity << ","
           << "\"wind_speed_kmh\":" << g_forestState.wind << ","
           << "\"smoke_co2_ppm\":" << g_forestState.co2 << ","
           << "\"flame_detected\":" << (flameDetected ? "true" : "false");
    }
    else if (envType == "disaster") {
        g_disasterState.flood = Clamp(g_disasterState.flood + GetRandomDelta(-0.3, 0.5), 0.0, 150.0);
        g_disasterState.seismic = Clamp(g_disasterState.seismic + GetRandomDelta(-0.003, 0.003), 0.01, 0.25);
        g_disasterState.aqi = ClampInt(g_disasterState.aqi + (rand() % 5 - 2), 40, 250);
        g_disasterState.gas = Clamp(g_disasterState.gas + GetRandomDelta(-0.2, 0.2), 0.0, 60.0);

        ss << std::fixed << std::setprecision(1)
           << "\"flood_level_cm\":" << g_disasterState.flood << ","
           << "\"seismic_vibration_g\":" << std::setprecision(3) << g_disasterState.seismic << ","
           << "\"air_quality_index\":" << g_disasterState.aqi << ","
           << "\"gas_leak_ppm\":" << std::setprecision(1) << g_disasterState.gas;
    }

    ss << "}}";

    std::string payload = ss.str();
    Ptr<Packet> packet = Create<Packet>((const uint8_t*)payload.c_str(), payload.length());
    socket->SendTo(packet, 0, InetSocketAddress(destAddr, port));

    Simulator::Schedule(Seconds(10.0), &SendTelemetry, socket, destAddr, port, envType, nodeId);
}

void GatewayReceive(Ptr<Socket> socket) {
    Ptr<Packet> packet;
    Address from;
    while ((packet = socket->RecvFrom(from))) {
        uint32_t size = packet->GetSize();
        std::vector<uint8_t> buffer(size + 1, 0);
        packet->CopyData(buffer.data(), size);
        std::string msg((char*)buffer.data(), size);

        std::cout << "[" << Simulator::Now().GetSeconds() << "s] GATEWAY RX: " << msg << std::endl;

        int pySock = ::socket(AF_INET, SOCK_DGRAM, 0);
        if (pySock >= 0) {
            struct sockaddr_in pyAddr;
            memset(&pyAddr, 0, sizeof(pyAddr));
            pyAddr.sin_family = AF_INET;
            pyAddr.sin_port = htons(9000);
            pyAddr.sin_addr.s_addr = inet_addr("127.0.0.1");
            ::sendto(pySock, msg.c_str(), msg.length(), 0, (struct sockaddr*)&pyAddr, sizeof(pyAddr));
            ::close(pySock);
        }
    }
}

int main(int argc, char *argv[]) {
    GlobalValue::Bind("SimulatorImplementationType", StringValue("ns3::RealtimeSimulatorImpl"));

    NodeContainer nodes;
    nodes.Create(30);
    // Nodes 0-9:   Agriculture Subnet (2D Diamond Mesh)
    // Nodes 10-19: Forest Subnet      (2D Diamond Mesh)
    // Nodes 20-29: Disaster Subnet    (2D Diamond Mesh)

    MobilityHelper mobility;
    Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator>();

    // --- 1. Agriculture 2D Diamond Grid (Y Offset = 0m) ---
    positionAlloc->Add(Vector(0.0,    0.0, 0.0));  // Node 0  (Agri Deep Source)
    positionAlloc->Add(Vector(30.0,  20.0, 0.0));  // Node 1  (Agri North Relay R1)
    positionAlloc->Add(Vector(30.0,   0.0, 0.0));  // Node 2  (Agri Center Relay R1)
    positionAlloc->Add(Vector(30.0, -20.0, 0.0));  // Node 3  (Agri South Relay R1)
    positionAlloc->Add(Vector(60.0,  20.0, 0.0));  // Node 4  (Agri North Relay R2)
    positionAlloc->Add(Vector(60.0,   0.0, 0.0));  // Node 5  (Agri Center Relay R2)
    positionAlloc->Add(Vector(60.0, -20.0, 0.0));  // Node 6  (Agri South Relay R2)
    positionAlloc->Add(Vector(90.0,  10.0, 0.0));  // Node 7  (Agri Egress North)
    positionAlloc->Add(Vector(90.0, -10.0, 0.0));  // Node 8  (Agri Egress South)
    positionAlloc->Add(Vector(120.0,  0.0, 0.0));  // Node 9  (Agri Gateway Sink)

    // --- 2. Forest 2D Diamond Grid (Y Offset = 200m) ---
    positionAlloc->Add(Vector(0.0,   200.0, 0.0)); // Node 10 (Forest Deep Source)
    positionAlloc->Add(Vector(30.0,  220.0, 0.0)); // Node 11 (Forest North Relay R1)
    positionAlloc->Add(Vector(30.0,  200.0, 0.0)); // Node 12 (Forest Center Relay R1)
    positionAlloc->Add(Vector(30.0,  180.0, 0.0)); // Node 13 (Forest South Relay R1)
    positionAlloc->Add(Vector(60.0,  220.0, 0.0)); // Node 14 (Forest North Relay R2)
    positionAlloc->Add(Vector(60.0,  200.0, 0.0)); // Node 15 (Forest Center Relay R2)
    positionAlloc->Add(Vector(60.0,  180.0, 0.0)); // Node 16 (Forest South Relay R2)
    positionAlloc->Add(Vector(90.0,  210.0, 0.0)); // Node 17 (Forest Egress North)
    positionAlloc->Add(Vector(90.0,  190.0, 0.0)); // Node 18 (Forest Egress South)
    positionAlloc->Add(Vector(120.0, 200.0, 0.0)); // Node 19 (Forest Gateway Sink)

    // --- 3. Disaster 2D Diamond Grid (Y Offset = 400m) ---
    positionAlloc->Add(Vector(0.0,   400.0, 0.0)); // Node 20 (Disaster Deep Source)
    positionAlloc->Add(Vector(30.0,  420.0, 0.0)); // Node 21 (Disaster North Relay R1)
    positionAlloc->Add(Vector(30.0,  400.0, 0.0)); // Node 22 (Disaster Center Relay R1)
    positionAlloc->Add(Vector(30.0,  380.0, 0.0)); // Node 23 (Disaster South Relay R1)
    positionAlloc->Add(Vector(60.0,  420.0, 0.0)); // Node 24 (Disaster North Relay R2)
    positionAlloc->Add(Vector(60.0,  400.0, 0.0)); // Node 25 (Disaster Center Relay R2)
    positionAlloc->Add(Vector(60.0,  380.0, 0.0)); // Node 26 (Disaster South Relay R2)
    positionAlloc->Add(Vector(90.0,  410.0, 0.0)); // Node 27 (Disaster Egress North)
    positionAlloc->Add(Vector(90.0,  390.0, 0.0)); // Node 28 (Disaster Egress South)
    positionAlloc->Add(Vector(120.0, 400.0, 0.0)); // Node 29 (Disaster Gateway Sink)

    mobility.SetPositionAllocator(positionAlloc);
    mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel");
    mobility.Install(nodes);

    // Wi-Fi Setup
    WifiHelper wifi;
    wifi.SetStandard(WIFI_STANDARD_80211a);
    wifi.SetRemoteStationManager("ns3::ConstantRateWifiManager",
                                 "DataMode", StringValue("OfdmRate6Mbps"),
                                 "ControlMode", StringValue("OfdmRate6Mbps"));

    YansWifiChannelHelper wifiChannel = YansWifiChannelHelper::Default();
    YansWifiPhyHelper wifiPhy;
    wifiPhy.SetChannel(wifiChannel.Create());

    WifiMacHelper wifiMac;
    wifiMac.SetType("ns3::AdhocWifiMac");

    NetDeviceContainer devices = wifi.Install(wifiPhy, wifiMac, nodes);

    // IP & AODV Stack
    AodvHelper aodv;
    InternetStackHelper stack;
    stack.SetRoutingHelper(aodv);
    stack.Install(nodes);

    Ipv4AddressHelper address;
    address.SetBase("10.1.1.0", "255.255.255.0");
    Ipv4InterfaceContainer interfaces = address.Assign(devices);

    // Socket Listeners on Local Domain Gateways (Port 8080)
    TypeId tid = TypeId::LookupByName("ns3::UdpSocketFactory");

    Ptr<Socket> recvAgriGW = Socket::CreateSocket(nodes.Get(9), tid);
    recvAgriGW->Bind(InetSocketAddress(Ipv4Address::GetAny(), 8080));
    recvAgriGW->SetRecvCallback(MakeCallback(&GatewayReceive));

    Ptr<Socket> recvForestGW = Socket::CreateSocket(nodes.Get(19), tid);
    recvForestGW->Bind(InetSocketAddress(Ipv4Address::GetAny(), 8080));
    recvForestGW->SetRecvCallback(MakeCallback(&GatewayReceive));

    Ptr<Socket> recvDisasterGW = Socket::CreateSocket(nodes.Get(29), tid);
    recvDisasterGW->Bind(InetSocketAddress(Ipv4Address::GetAny(), 8080));
    recvDisasterGW->SetRecvCallback(MakeCallback(&GatewayReceive));

    // Schedule Telemetry Transmissions for all field nodes
    double offset = 2.0;
    // Agriculture Cluster Transmissions
    for (int i = 0; i < 9; ++i) {
        Ptr<Socket> s = Socket::CreateSocket(nodes.Get(i), tid);
        std::string name = "Agri_Node" + std::to_string(i);
        Simulator::Schedule(Seconds(offset), &SendTelemetry, s, interfaces.GetAddress(9), 8080, "agriculture", name);
        offset += 0.2;
    }

    // Forest Cluster Transmissions
    for (int i = 10; i < 19; ++i) {
        Ptr<Socket> s = Socket::CreateSocket(nodes.Get(i), tid);
        std::string name = "Forest_Node" + std::to_string(i);
        Simulator::Schedule(Seconds(offset), &SendTelemetry, s, interfaces.GetAddress(19), 8080, "forest", name);
        offset += 0.2;
    }

    // Disaster Cluster Transmissions
    for (int i = 20; i < 29; ++i) {
        Ptr<Socket> s = Socket::CreateSocket(nodes.Get(i), tid);
        std::string name = "Disaster_Node" + std::to_string(i);
        Simulator::Schedule(Seconds(offset), &SendTelemetry, s, interfaces.GetAddress(29), 8080, "disaster", name);
        offset += 0.2;
    }

    // Fault Injection Test: Kill Agriculture Node 1 between 30s and 60s
    Ptr<Ipv4> ipv4AgriNode1 = nodes.Get(1)->GetObject<Ipv4>();

    Simulator::Schedule(Seconds(30.0), []() {
        std::cout << "\n=================== [30.0s] AGRI NODE 1 KILLED (AODV REROUTING VIA NODE 2/3) ===================\n" << std::endl;
    });
    Simulator::Schedule(Seconds(30.0), &Ipv4::SetDown, ipv4AgriNode1, 1);

    Simulator::Schedule(Seconds(60.0), []() {
        std::cout << "\n=================== [60.0s] AGRI NODE 1 RECOVERED ===================\n" << std::endl;
    });
    Simulator::Schedule(Seconds(60.0), &Ipv4::SetUp, ipv4AgriNode1, 1);

    Simulator::Stop(Seconds(3600.0));
    Simulator::Run();
    Simulator::Destroy();
    return 0;
}