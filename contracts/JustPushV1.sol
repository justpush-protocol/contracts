// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/IJustPushV1.sol";

contract JustPushV1 is IJustPushV1 {
    uint256 public groupCount;
    mapping(uint256 => Group) public groups;
    mapping(address => User) public users;

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
        mapping(address => bool) isNotifier;
        /**
         * @notice Represents the state of the group.
         * 0 - inactive
         * 1 - active
         * 3 - deactivated
         * 4 - blocked
         */
        uint8 state;
        /**
         * @notice A Json string that holds the group name, description, and other metadata.
         * Can only be updated by the group owner.
         *  {
         *      "name" : "JustLend",
         *      "description" : "JustLend notifications",
         *      "website" : "https://justlend.io",
         *      "logo:" : "https://justlend.io/logo.png"
         *  }
         */
        string data;
        /**
         * @notice Represents whether the group is a verified group.
         * By default all groups are unverified.
         * Popular dapps (justlend, justswap, etc) can be verified by JustPush governance.
         */
        bool verified;
        /** @notice Represent when the group was created */
        uint256 createdAt;
    }

    struct User {
        /**
         * @notice Represents the state of the user.
         * 0 - inactive
         * 1 - active
         */
        uint8 state;
        /**
         * @notice Represents the user's subscription to a group.
         * 0 - not interacted
         * 1 - subscribed
         * 2 - unsubscribed
         */
        mapping(uint256 => uint8) isSubscribed;
        /** @notice Keeps track off all subscribed (and later might have unsubscribed) groups */
        uint256[] groupsInteractedWith;
        /** Number of total subscribed groups */
        uint256 subscribedGroupsCount;
        /** @notice Represent when the user was created */
        uint256 createdAt;
    }

    modifier onlyGovernance() {
        require(
            msg.sender == justPushGovernance,
            "JustPushV1::onlyGovernance: Only governance can call this function"
        );
        _;
    }

    modifier onlyGroupOwner(uint256 _groupId) {
        require(
            groups[_groupId].owner == msg.sender ||
                msg.sender == justPushGovernance,
            "JustPushV1::onlyGroupOwner: Only owner can call this function"
        );
        _;
    }

    modifier onlyNotifier(uint256 _groupId) {
        require(
            groups[_groupId].isNotifier[msg.sender] ||
                groups[_groupId].owner == msg.sender ||
                msg.sender == justPushGovernance,
            "JustPushV1::onlyNotifier: Only notifier can call this function"
        );
        _;
    }

    modifier activeGroup(uint256 _groupId) {
        require(
            groups[_groupId].state == 1,
            "JustPushV1::activeGroup: Group is not active"
        );
        _;
    }

    modifier inactiveGroup(uint256 _groupId) {
        require(
            groups[_groupId].state == 0,
            "JustPushV1::inactiveGroup: Group is not inactive"
        );
        _;
    }

    modifier activeUser() {
        require(
            users[msg.sender].state == 1,
            "JustPushV1::activeUser: User is not active"
        );
        _;
    }

    modifier subscribedUser(uint256 _groupId, address _user) {
        require(
            users[_user].isSubscribed[_groupId] == 1,
            "JustPushV1::subscribedUser: User is not subscribed"
        );
        _;
    }

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
     * @param _data A Json string that holds the group name, description, and other metadata.
     * @return groupId The id of the newly created group.
     */
    function createGroup(string memory _data)
        external
        override
        returns (uint256 groupId)
    {
        groupId = groupCount;
        groups[groupId].state = 1;
        groups[groupId].owner = msg.sender;
        groups[groupId].data = _data;
        groups[groupId].createdAt = block.timestamp;
        groupCount++;

        // todo: subscribe to the owner to the group
        // todo: subscribe owner to the push protocol communication group
        return groupId;
    }

    /**
     * @notice Updates the group data.
     * @param _groupId The id of the group.
     * @param _data A Json string that holds the group name, description, and other metadata.
     */
    function changeData(uint256 _groupId, string memory _data)
        external
        override
        onlyGroupOwner(_groupId)
    {
        groups[_groupId].data = _data;
    }

    /**
     * @notice Adds a new notifier to the group.
     * @param _groupId The id of the group.
     * @param _notifier The address of the notifier.
     */
    function addNotifier(uint256 _groupId, address _notifier)
        external
        override
        onlyGroupOwner(_groupId)
    {
        require(
            !groups[_groupId].isNotifier[_notifier],
            "JustPushV1::addNotifier: Notifier already exists"
        );
        groups[_groupId].notifiers.push(_notifier);
        groups[_groupId].isNotifier[_notifier] = true;
    }

    /**
     * @notice Removes a notifier from the group.
     * @param _groupId The id of the group.
     * @param _notifier The address of the notifier.
     */
    function disableNotifier(uint256 _groupId, address _notifier)
        external
        override
        onlyGroupOwner(_groupId)
    {
        require(
            groups[_groupId].isNotifier[_notifier],
            "JustPushV1::disableNotifier: Notifier does not exist"
        );
        groups[_groupId].isNotifier[_notifier] = false;
    }

    /**
     * @notice Changes the group owner.
     * @param _groupId The id of the group.
     * @param _newOwner The address of the new owner.
     */
    function changeGroupOwner(uint256 _groupId, address _newOwner)
        external
        override
        onlyGroupOwner(_groupId)
    {
        groups[_groupId].owner = _newOwner;
        // todo: subscribe to the new owner to the group
        // todo: subscribe the new owner to the push protocol communication group
    }

    /**
     * @notice Deactivates a group.
     * @param _groupId The id of the group.
     */
    function deactivateGroup(uint256 _groupId)
        external
        override
        onlyGroupOwner(_groupId)
        activeGroup(_groupId)
    {
        groups[_groupId].state = 3;
    }

    /**
     * @notice Activates a group.
     * @param _groupId The id of the group.
     */
    function activateGroup(uint256 _groupId)
        external
        override
        onlyGroupOwner(_groupId)
        inactiveGroup(_groupId)
    {
        groups[_groupId].state = 1;
    }

    /**
     * @notice Blocks a group.
     * @param _groupId The id of the group.
     */
    function blockGroup(uint256 _groupId) external override onlyGovernance {
        groups[_groupId].state = 4;
    }

    /**
     * @notice Verifies a group.
     * @param _groupId The id of the group.
     */
    function verifyGroup(uint256 _groupId) external override onlyGovernance {
        groups[_groupId].verified = true;
    }

    /**
     * @notice Unverifies a group.
     * @param _groupId The id of the group.
     */
    function unverifyGroup(uint256 _groupId) external override onlyGovernance {
        groups[_groupId].verified = false;
    }

    /**
     * @notice Verifies batch of groups.
     * @param _groupIds The ids of the groups.
     */
    function batchVerifyGroups(uint256[] memory _groupIds)
        external
        override
        onlyGovernance
    {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            groups[_groupIds[i]].verified = true;
        }
    }

    /**
     * @notice Subscribes a user to a group.
     * @param _groupId The id of the group.
     */
    function subscribe(uint256 _groupId)
        external
        override
        activeUser
        activeGroup(_groupId)
    {
        _subscribe(_groupId, msg.sender);
    }

    /**
     * @notice Batch subscribe a user to multiple groups.
     * @param _groupIds The ids of the groups.
     */
    function batchSubscribe(uint256[] memory _groupIds)
        external
        override
        activeUser
    {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            _subscribe(_groupIds[i], msg.sender);
        }
    }

    /**
     * @notice Unsubscribes a user from a group.
     * @param _groupId The id of the group.
     */
    function unsubscribe(uint256 _groupId)
        external
        override
        activeUser
        activeGroup(_groupId)
    {
        _unsubscribe(_groupId, msg.sender);
    }

    /**
     * @notice Batch unsubscribe a user from multiple groups.
     * @param _groupIds The ids of the groups.
     */
    function batchUnsubscribe(uint256[] memory _groupIds)
        external
        override
        activeUser
    {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            _unsubscribe(_groupIds[i], msg.sender);
        }
    }

    function _subscribe(uint256 _groupId, address _user)
        private
        activeGroup(_groupId)
    {
        User storage user = users[_user];
        if (user.isSubscribed[_groupId] == 0) {
            user.isSubscribed[_groupId] = 1;
            user.subscribedGroupsCount = user.subscribedGroupsCount + 1;
            user.groupsInteractedWith.push(_groupId);
        } else if (user.isSubscribed[_groupId] == 2) {
            user.isSubscribed[_groupId] = 1;
            user.subscribedGroupsCount = user.subscribedGroupsCount + 1;
        }
    }

    function _unsubscribe(uint256 _groupId, address _user)
        private
        activeGroup(_groupId)
    {
        User storage user = users[_user];
        if (user.isSubscribed[_groupId] == 1) {
            user.isSubscribed[_groupId] = 2;
            user.subscribedGroupsCount = user.subscribedGroupsCount - 1;
        }
    }
}
