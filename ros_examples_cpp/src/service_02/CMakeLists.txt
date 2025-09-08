cmake_minimum_required(VERSION 3.8)
project(service_02)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(example_interfaces REQUIRED)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # comment the line when a copyright and license is added to all source files
  set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # comment the line when this package is in a git repo and when
  # a copyright and license is added to all source files
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

# ----- Necessary CMake Calls to add your ROS2 Node -----

# Make executable and add your libraries
add_executable(server src/add_two_ints_server.cpp)
add_executable(client src/add_two_ints_client.cpp)

target_link_libraries(server PUBLIC 
    rclcpp::rclcpp 
    ${example_interfaces_TARGETS}
)

target_link_libraries(client PUBLIC 
    rclcpp::rclcpp 
    ${example_interfaces_TARGETS}
)

# Specify install function so ROS2 can find your node.
install(TARGETS 
    server 
    client
    DESTINATION lib/${PROJECT_NAME}
)

ament_package()
