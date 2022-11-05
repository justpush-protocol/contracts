// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/IJustPushV1.sol";
import "./interfaces/IBroadcastNotificationSender.sol";
import "./interfaces/IDirectNotificationSender.sol";

contract JustPushV1 is
    IJustPushV1,
    IBroadcastNotificationSender,
    IDirectNotificationSender
{
    uint256 public groupCount;
    mapping(string => Group) public groups;
    mapping(string => mapping(address => bool)) public groupNotifiers;

    address public justPushGovernance;

    /// @notice Represents a notification group
    struct Group {
        /**
         * @notice Owner of the group.
         * The owner can
         *     - change group data (name, description, etc.)
         *     - delegate notifiers
         *     - assign a new owner
         */
        address owner;
        /**
         * @notice Notifiers of the group.
         * The notifiers can
         *     - push notifications
         */
        address[] notifiers;
        /**
         * @notice Represents the state of the group.
         * 0 - inactive
         * 1 - active
         * 3 - deactivated
         * 4 - blocked
         */
        uint8 state;
        /**
         * @notice Represents whether the group is a verified group.
         * By default all groups are unverified.
         * Popular dapps (justlend, justswap, etc) can be verified by JustPush governance.
         */
        bool verified;
        /** @notice Represent when the group was created */
        uint256 createdAt;
    }

    modifier onlyGovernance() {
        require(
            msg.sender == justPushGovernance,
            "JustPushV1::onlyGovernance: Only governance can call this function"
        );
        _;
    }

    modifier onlyGroupOwner(string memory _groupId) {
        require(
            groups[_groupId].owner == msg.sender ||
                msg.sender == justPushGovernance,
            "JustPushV1::onlyGroupOwner: Only owner can call this function"
        );
        _;
    }

    modifier onlyNotifier(string memory _groupId) {
        require(
            groupNotifiers[_groupId][msg.sender] == true ||
                groups[_groupId].owner == msg.sender ||
                msg.sender == justPushGovernance,
            "JustPushV1::onlyNotifier: Only notifier can call this function"
        );
        _;
    }

    modifier activeGroup(string memory _groupId) {
        require(
            groups[_groupId].state == 1,
            "JustPushV1::activeGroup: Group is not active"
        );
        _;
    }

    modifier inactiveGroup(string memory _groupId) {
        require(
            groups[_groupId].state == 0,
            "JustPushV1::inactiveGroup: Group is not inactive"
        );
        _;
    }

    // Events
    event GroupCreated(
        string groupId,
        address owner,
        string data,
        uint256 createdAt
    );

    event NotifierAdded(string groupId, address notifier);

    event NotifierRemoved(string groupId, address notifier);

    event BroadcastNotificationSent(
        string groupId,
        address notifier,
        string title,
        string content,
        uint256 createdAt
    );

    event DirectNotificationSent(
        string groupId,
        address notifier,
        address receiver,
        string title,
        string content,
        uint256 createdAt
    );

    event GroupOwnerChanged(string groupId, address oldOwner, address newOwner);

    event GroupStateChanged(string groupId, uint8 oldState, uint8 newState);

    event SubscripitonChanged(
        string groupId,
        address subscriber,
        bool subscribed
    );

    event GroupVerified(string groupId, bool verified);

    event GovernanceChanged(address oldGovernance, address newGovernance);

    /**
     * @notice Initializes the protocol.
     * @param _justPushGovernance The address of the JustPush governance.
     */
    function initialize(address _justPushGovernance) external override {
        require(
            justPushGovernance == address(0),
            "JustPushV1::initialize: Already initialized"
        );
        justPushGovernance = _justPushGovernance;
    }

    /**
     * @notice Creates a new notification group.
     * @param _id A unique identifier for the group.
     * @param _owner Owner of the group.
     * @param _data A Json string that holds the group name, description, and other metadata.
     */
    function createGroup(
        string memory _id,
        address _owner,
        string calldata _data
    ) external override {
        groupCount = groupCount + 1;
        require(
            groups[_id].state == 0,
            "JustPushV1::createGroup: Group already exists."
        );
        groups[_id].state = 1;
        groups[_id].owner = _owner;
        groups[_id].createdAt = block.timestamp;

        emit GroupCreated(_id, _owner, _data, block.timestamp);
    }

    /**
     * @notice Get group data.
     * @param _groupId The id of the group.
     */
    function getGroup(string memory _groupId)
        external
        view
        returns (Group memory)
    {
        return groups[_groupId];
    }

    /**
     * @notice Send broadcast notification to a group.
     * @param _groupId The id of the group.
     * @param _title The title of the notification.
     * @param _content The content of the notification.
     */
    function sendBroadcastNotification(
        string memory _groupId,
        string calldata _title,
        string calldata _content
    ) external override onlyNotifier(_groupId) activeGroup(_groupId) {
        emit BroadcastNotificationSent(
            _groupId,
            msg.sender,
            _title,
            _content,
            block.timestamp
        );
    }

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
    ) external override onlyNotifier(_groupId) activeGroup(_groupId) {
        emit DirectNotificationSent(
            _groupId,
            msg.sender,
            _receiver,
            _title,
            _content,
            block.timestamp
        );
    }

    /**
     * @notice Adds a new notifier to the group.
     * @param _groupId The id of the group.
     * @param _notifier The address of the notifier.
     */
    function addNotifier(string memory _groupId, address _notifier)
        external
        override
        onlyGroupOwner(_groupId)
    {
        require(
            groupNotifiers[_groupId][_notifier] == false,
            "JustPushV1::addNotifier: Notifier already exists"
        );
        groups[_groupId].notifiers.push(_notifier);
        groupNotifiers[_groupId][_notifier] = true;
        emit NotifierAdded(_groupId, _notifier);
    }

    /**
     * @notice Removes a notifier from the group.
     * @param _groupId The id of the group.
     * @param _notifier The address of the notifier.
     */
    function disableNotifier(string memory _groupId, address _notifier)
        external
        override
        onlyGroupOwner(_groupId)
    {
        require(
            groupNotifiers[_groupId][_notifier] == true,
            "JustPushV1::disableNotifier: Notifier does not exist"
        );
        groupNotifiers[_groupId][_notifier] = false;
        emit NotifierRemoved(_groupId, _notifier);
    }

    /**
     * @notice Changes the group owner.
     * @param _groupId The id of the group.
     * @param _newOwner The address of the new owner.
     */
    function changeGroupOwner(string memory _groupId, address _newOwner)
        external
        override
        onlyGroupOwner(_groupId)
    {
        groups[_groupId].owner = _newOwner;
        emit GroupOwnerChanged(_groupId, msg.sender, _newOwner);
    }

    /**
     * @notice Deactivates a group.
     * @param _groupId The id of the group.
     */
    function deactivateGroup(string memory _groupId)
        external
        override
        onlyGroupOwner(_groupId)
        activeGroup(_groupId)
    {
        groups[_groupId].state = 3;
        emit GroupStateChanged(_groupId, 1, 3);
    }

    /**
     * @notice Activates a group.
     * @param _groupId The id of the group.
     */
    function activateGroup(string memory _groupId)
        external
        override
        onlyGroupOwner(_groupId)
        inactiveGroup(_groupId)
    {
        groups[_groupId].state = 1;
        emit GroupStateChanged(_groupId, 0, 1);
    }

    /**
     * @notice Blocks a group.
     * @param _groupId The id of the group.
     */
    function blockGroup(string memory _groupId)
        external
        override
        onlyGovernance
    {
        uint8 previous = groups[_groupId].state;
        groups[_groupId].state = 4;
        emit GroupStateChanged(_groupId, previous, 4);
    }

    /**
     * @notice Verifies a group.
     * @param _groupId The id of the group.
     */
    function verifyGroup(string memory _groupId)
        external
        override
        onlyGovernance
    {
        groups[_groupId].verified = true;
        emit GroupVerified(_groupId, true);
    }

    /**
     * @notice Unverifies a group.
     * @param _groupId The id of the group.
     */
    function unverifyGroup(string memory _groupId)
        external
        override
        onlyGovernance
    {
        groups[_groupId].verified = false;
        emit GroupVerified(_groupId, false);
    }

    /**
     * @notice Verifies batch of groups.
     * @param _groupIds The ids of the groups.
     */
    function batchVerifyGroups(string[] memory _groupIds)
        external
        override
        onlyGovernance
    {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            groups[_groupIds[i]].verified = true;
            emit GroupVerified(_groupIds[i], true);
        }
    }

    /**
     * @notice Subscribes a user to a group.
     * @param _groupId The id of the group.
     */
    function subscribe(string memory _groupId)
        external
        override
        activeGroup(_groupId)
    {
        _subscribe(_groupId, msg.sender);
    }

    /**
     * @notice Batch subscribe a user to multiple groups.
     * @param _groupIds The ids of the groups.
     */
    function batchSubscribe(string[] memory _groupIds) external override {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            _subscribe(_groupIds[i], msg.sender);
        }
    }

    /**
     * @notice Unsubscribes a user from a group.
     * @param _groupId The id of the group.
     */
    function unsubscribe(string memory _groupId)
        external
        override
        activeGroup(_groupId)
    {
        _unsubscribe(_groupId, msg.sender);
    }

    /**
     * @notice Batch unsubscribe a user from multiple groups.
     * @param _groupIds The ids of the groups.
     */
    function batchUnsubscribe(string[] memory _groupIds) external override {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            _unsubscribe(_groupIds[i], msg.sender);
        }
    }

    function changeGovernace(address _newGovernance)
        external
        override
        onlyGovernance
    {
        justPushGovernance = _newGovernance;
        emit GovernanceChanged(msg.sender, _newGovernance);
    }

    function _subscribe(string memory _groupId, address _user)
        private
        activeGroup(_groupId)
    {
        emit SubscripitonChanged(_groupId, _user, true);
    }

    function _unsubscribe(string memory _groupId, address _user)
        private
        activeGroup(_groupId)
    {
        emit SubscripitonChanged(_groupId, _user, true);
    }
}
