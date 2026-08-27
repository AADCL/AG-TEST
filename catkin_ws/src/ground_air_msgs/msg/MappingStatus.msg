std_msgs/Header header

uint8 IDLE=0
uint8 RECORDING=1
uint8 SAVING=2
uint8 COMPLETE=3
uint8 ERROR=4

uint8 state
string map_id
uint64 point_count
float64 map_area
string message
