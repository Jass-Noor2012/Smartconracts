
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GameSocial {
    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 likes;
    }

    uint256 public nextPostId;
    mapping(uint256 => Post) public posts;
    mapping(address => uint256[]) public userPosts;
    mapping(uint256 => mapping(address => bool)) public postLikes;
    mapping(address => mapping(address => bool)) public userFollows;

    address public owner;
    uint256 public postFee = 0.01 ether;
    uint256 public likeFee = 0.005 ether;
    uint256 public followFee = 0.02 ether;

    event PostCreated(uint256 id, address indexed author, string content);
    event PostLiked(uint256 id, address indexed liker);
    event UserFollowed(address indexed follower, address indexed followed);
    event UserUnfollowed(address indexed follower, address indexed unfollowed);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function createPost(string memory _content) public payable {
        require(msg.value >= postFee, "Insufficient ETH to create a post.");
        posts[nextPostId] = Post(nextPostId, msg.sender, _content, 0);
        userPosts[msg.sender].push(nextPostId);

        emit PostCreated(nextPostId, msg.sender, _content);
        nextPostId++;
    }

    function likePost(uint256 _postId) public payable {
        require(posts[_postId].author != address(0), "Post does not exist.");
        require(msg.value >= likeFee, "Insufficient ETH to like a post.");
        require(!postLikes[_postId][msg.sender], "You already liked this post.");

        posts[_postId].likes++;
        postLikes[_postId][msg.sender] = true;

        emit PostLiked(_postId, msg.sender);
    }

    function followUser(address _user) public payable {
        require(msg.sender != _user, "You cannot follow yourself.");
        require(msg.value >= followFee, "Insufficient ETH to follow a user.");
        require(!userFollows[msg.sender][_user], "You already follow this user.");

        userFollows[msg.sender][_user] = true;

        emit UserFollowed(msg.sender, _user);
    }

    function unfollowUser(address _user) public {
        require(userFollows[msg.sender][_user], "You do not follow this user.");

        userFollows[msg.sender][_user] = false;

        emit UserUnfollowed(msg.sender, _user);
    }

    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);

        emit FundsWithdrawn(owner, balance);
    }
}
