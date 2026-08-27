std_msgs/Header header

uint8 UNKNOWN=0
uint8 GROUND=1
uint8 TAKEOFF=2
uint8 AIR=3
uint8 LANDING=4
uint8 ESTOP=5
uint8 FAULT=6

uint8 mode
bool connected
bool armed
bool localized
bool emergency_stop
float32 altitude
string flight_mode
string detail
