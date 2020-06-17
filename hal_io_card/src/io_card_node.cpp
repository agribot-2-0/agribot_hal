#include <hal_iocard/IoCard.h>

#include <ros/ros.h>
#include <ros/console.h>
#include <agribot_msgs/IoCard.h>

IoCard g_IoControl(OUTPUT | INPUT);

bool bScan(agribot_msgs::IoCard::Request &req,
           agribot_msgs::IoCard::Response &res)
{
    if(req.set_do_port0 == true)
    {
        g_IoControl.vWritePort(PORT0, (uint8_t)req.port0_mask);
    }
    if(req.set_do_port1 == true)
    {
        g_IoControl.vWritePort(PORT1, (uint8_t)req.port1_mask);
    }
    if(req.read_port0 == true)
    {
        res.port0_state = g_IoControl.u8ReadPort(PORT0);
    }
    if(req.read_port1 == true)
    {
        res.port1_state = g_IoControl.u8ReadPort(PORT1);
    }
    return true;
}
/*
void setPortVal0(const std_msgs::UInt8::ConstPtr& msg)
{
    g_outTest.vWritePort(PORT0, (uint8_t)msg->data);
    ROS_INFO("DO0: 0x%X", (uint8_t)msg->data);
}

void setPortVal1(const std_msgs::UInt8::ConstPtr& msg)
{
    g_outTest.vWritePort(PORT1, (uint8_t)msg->data);
    ROS_INFO("DO1: 0x%X", (uint8_t)msg->data);
}
*/
int main(int argc, char **argv)
{
    ros::init(argc, argv, "iocard");
    ros::NodeHandle n;
    ros::Rate loop_rate(1);
    
    while (ros::ok())
    {
        ros::spinOnce();
        loop_rate.sleep();
    }

    return 0;
}
