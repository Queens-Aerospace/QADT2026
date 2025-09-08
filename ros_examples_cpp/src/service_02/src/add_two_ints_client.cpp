#include <chrono>
#include <cinttypes>
#include <memory>

#include "example_interfaces/srv/add_two_ints.hpp"
#include "rclcpp/rclcpp.hpp"

using AddTwoInts = example_interfaces::srv::AddTwoInts;

int main(int argc, char *argv[])
{
    rclcpp::init(argc, argv);
    auto node = rclcpp::Node::make_shared("client");
    auto client = node->create_client<AddTwoInts>("add_two_ints");

    size_t counter = 0;
    while (!client->wait_for_service(std::chrono::seconds(1)))
    {
        if (!rclcpp::ok())
        {
            RCLCPP_ERROR(node->get_logger(), "client interrupted while waiting for service to appear.");
            return 1;
        }
        RCLCPP_INFO(node->get_logger(), "waiting for service to appear. attempt: %zu...", ++counter);
    }
    auto request = std::make_shared<AddTwoInts::Request>();
    request->a = 41;
    request->b = 1;

    // Send request and obtain future to track request status.
    auto result_future = client->async_send_request(request);

    // Spin node until our future returns a successful return code. If not
    // return a log error and exit program with 'return 1'
    if (rclcpp::spin_until_future_complete(node, result_future) !=
        rclcpp::FutureReturnCode::SUCCESS)
    {
        RCLCPP_ERROR(node->get_logger(), "service call failed :(");
        client->remove_pending_request(result_future);
        return 1;
    }

    auto result = result_future.get();
    RCLCPP_INFO(node->get_logger(), "result of %ld + %ld = %ld", request->a, request->b, result->sum);
    rclcpp::shutdown();
    return 0;
}