#############################################################################
## Set minimum required version of cmake, project name and compile options ##
#############################################################################
cmake_minimum_required(VERSION 2.8.3)
project(hal_io_card)

set(CMAKE_VERBOSE_MAKEFILE ON)

#############################################################################
## Find catkin packages and libraries for catkin and system dependencies   ##
#############################################################################
find_package(catkin REQUIRED COMPONENTS
  roscpp
  agribot_msgs
)

################################################
## Declare ROS messages, services and actions ##
################################################

################################################
## Declare ROS dynamic reconfigure parameters ##
################################################

###################################
## catkin specific configuration ##
###################################
catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES can
#  CATKIN_DEPENDS other_catkin_pkg
#  DEPENDS system_lib
)

#############################################################################
## Build                                                                   ##
#############################################################################
include_directories(
 include
 ${catkin_INCLUDE_DIRS}
)
link_directories("${PROJECT_SOURCE_DIR}")
add_executable(hal_io_card src/IoCard.cpp src/io_card_node.cpp)
target_link_libraries(hal_io_card ${catkin_LIBRARIES} -lbiodaq)
add_dependencies(hal_io_card ${catkin_EXPORTED_TARGETS})

#############
## Install ##
#############

install(TARGETS
  hal_io_card
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
  LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
)

#############
## Testing ##
#############
