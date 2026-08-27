std_msgs/Header header

uint8 IDLE=0
uint8 RUNNING=1
uint8 DWELLING=2
uint8 PAUSED=3
uint8 SUCCEEDED=4
uint8 FAILED=5
uint8 CANCELED=6
uint8 WAITING_FOR_LAND=7

uint8 state
uint32 current_index
uint32 total_goals
string mission_id
string detail
