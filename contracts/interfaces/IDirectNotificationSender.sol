// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

// Use this interface to send notifications to a subscrber directly.
interface IDirectNotificationSender {
    /**
     * @notice Send notification to a group.
     * @param _groupId The id of the group.
     * @param _receiver The address of the receiver.
     * @param _title The title of the notification.
     * @param _content The content of the notification.
     */
    function sendNotification(
        string memory _groupId,
        address _receiver,
        string calldata _title,
        string calldata _content
    ) external;
}
