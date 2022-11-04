// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

// Use this interface to send broadcast notifications to JustPush.
interface IBroadcastNotificationSender {
    /**
     * @notice Sends a broadcast notification to JustPush.
     * @param _groupId The id of the group.
     * @param _title The title of the notification.
     * @param _content The body of the notification.
     */
    function sendBroadcastNotification(
        string memory _groupId,
        string calldata _title,
        string calldata _content
    ) external;
}
