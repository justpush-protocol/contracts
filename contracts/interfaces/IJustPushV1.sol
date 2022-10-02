// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IJustPushV1 {
    /**
     * @notice Initializes the protocol.
     * @param _justPushGovernance The address of the JustPush governance.
     */
    function initialize(address _justPushGovernance) external;

    /**
     * @notice Creates a new notification group.
     * @param _data A Json string that holds the group name, description, and other metadata.
     * @return groupId The id of the newly created group.
     */
    function createGroup(string memory _data)
        external
        returns (uint256 groupId);

    /**
     * @notice Updates the group data.
     * @param _groupId The id of the group.
     * @param _data A Json string that holds the group name, description, and other metadata.
     */
    function changeData(uint256 _groupId, string memory _data) external;

    /**
     * @notice Adds a new notifier to the group.
     * @param _groupId The id of the group.
     * @param _notifier The address of the notifier.
     */
    function addNotifier(uint256 _groupId, address _notifier) external;

    /**
     * @notice Removes a notifier from the group.
     * @param _groupId The id of the group.
     * @param _notifier The address of the notifier.
     */
    function disableNotifier(uint256 _groupId, address _notifier) external;

    /**
     * @notice Changes the group owner.
     * @param _groupId The id of the group.
     * @param _newOwner The address of the new owner.
     */
    function changeGroupOwner(uint256 _groupId, address _newOwner) external;

    /**
     * @notice Deactivates a group.
     * @param _groupId The id of the group.
     */
    function deactivateGroup(uint256 _groupId) external;

    /**
     * @notice Activates a group.
     * @param _groupId The id of the group.
     */
    function activateGroup(uint256 _groupId) external;

    /**
     * @notice Blocks a group.
     * @param _groupId The id of the group.
     */
    function blockGroup(uint256 _groupId) external;

    /**
     * @notice Verifies a group.
     * @param _groupId The id of the group.
     */
    function verifyGroup(uint256 _groupId) external;

    /**
     * @notice Unverifies a group.
     * @param _groupId The id of the group.
     */
    function unverifyGroup(uint256 _groupId) external;

    /**
     * @notice Verifies batch of groups.
     * @param _groupIds The ids of the groups.
     */
    function batchVerifyGroups(uint256[] memory _groupIds) external;

    /**
     * @notice Subscribes a user to a group.
     * @param _groupId The id of the group.
     */
    function subscribe(uint256 _groupId) external;

    /**
     * @notice Batch subscribe a user to multiple groups.
     * @param _groupIds The ids of the groups.
     */
    function batchSubscribe(uint256[] memory _groupIds) external;

    /**
     * @notice Unsubscribes a user from a group.
     * @param _groupId The id of the group.
     */
    function unsubscribe(uint256 _groupId) external;

    /**
     * @notice Batch unsubscribe a user from multiple groups.
     * @param _groupIds The ids of the groups.
     */
    function batchUnsubscribe(uint256[] memory _groupIds) external;
}
