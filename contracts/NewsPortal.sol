// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract NewsPortal {

    struct Post {
        uint id;
        string genre;
        string title;
        string content;
        uint commentsPerPostID;
    }

    struct Comment {
        uint id;
        uint postID;
        address userWriter;
        string content;
        uint numberOfCharacters; //this is the length of the comment

    }

    address private writer; //this is the one and only admin
    address private usersAddress; //used to save users address from mapping, into a variable, so that user can be also deleted from users array

    uint private id = 1; //ID, that will be used to count number of posts and increment for each new post, we started with 1, because that is more natural
    uint private commentsPerPostID = 0; //number of comments per post
    uint private userID = 1; //counter to count the number of users, we started with 1, because that is more natural

    mapping(uint => Post) allPosts; // used to store all posts, key: postID, value: Post struct
    mapping(string => Post[]) postPerGenre; //used to store posts per genre, key:genre, value:arrays of post structs
    mapping(uint => Comment[]) commentsPerPost; //key:post ID, value:array of comment structs
    mapping(uint => uint) commentsCountPerPost;
    mapping(uint => mapping(address => bool)) commentWritersPerPostIDMapping;  //key: post ID, value: another mapping(user's address => T/F), depending if they commented or not

    Post[] posts;  //list of all posts 
    Comment[] comments; //list of all comments 

    //address[] commentWritersPerPostArray; 

    event newPostCreatedEvent(uint id, string genre, string title, string content);
    event commentWrittenEvent(uint postID, uint commentID);
    event PostDeletedEvent(uint id);
    
    //modifiers to increment and decrement number of posts, and to increment number of comments

    modifier incrementPostCounter(){  
        _;
        id += 1;
    }

    modifier decrementPostCounter(){
        _;
        id -= 1;
    }

    
    modifier incrementCommentCounter(){
        _;
        commentsPerPostID += 1;
    }

    //access control modifiers, some actions are allowed only to admin, and some are prohibited to admin

    modifier onlyAdmin(){
        require(msg.sender == writer, "You need to be an admin to perform this action.");
        _;
    }

    modifier onlyUser(){
        require(msg.sender != writer, "You have to be logged in as a user for this.");
        _;
    }

    //modifier to check comment character limit

    modifier checkCommentLength(string memory comment) {
        require(bytes(comment).length <= 250, "You went over character limit of 250!");
        _;
    }

    //modifier to restrict users to write only one comment per post

    modifier spamControl(uint _postID) {
        require(!commentWritersPerPostIDMapping[_postID][msg.sender], "You can write only one comment per post.");
        _;
    }

    constructor(){
        writer = msg.sender; //this is the one and only admin
    }

    //function to write posts by an admin
    function writePosts(string memory _genre, string memory _title, string memory _content) external incrementPostCounter onlyAdmin {

        
        // Create a new Post 
        Post memory newPost = Post(id, _genre, _title, _content, 0);
        posts.push(newPost);

        // we also need to add new post to both mappings that are reated to post structs
        postPerGenre[_genre].push(newPost);
        allPosts[id] = newPost;

        //emit an event that the new post is created
        emit newPostCreatedEvent(id, _genre, _title, _content);
    }

    //function to delete posts by an admin
    //posts need to be deleted in 3 seperate places, two mappings and one array
    function deletePost(uint _id) external onlyAdmin decrementPostCounter {
        string memory extractGenre = allPosts[_id].genre;

        // first, we found index of the post to delete
        uint indexToDelete = findPostIndex(postPerGenre[extractGenre], _id);

        // If the post is in right array, by guessing the right genre, then delete it
        if (indexToDelete < postPerGenre[extractGenre].length) {
            // we also swapped positions of the last item in the array and the one we want to delete
            postPerGenre[extractGenre][indexToDelete] = postPerGenre[extractGenre][postPerGenre[extractGenre].length - 1];
            postPerGenre[extractGenre].pop();
        }

        //It also needs to be deleted from posts, array of structs
        //Same procedure as above will be followed
        uint postsIndexToDelete = findPostIndex(posts, _id);

        if (postsIndexToDelete < posts.length) {
            posts[postsIndexToDelete] = posts[posts.length - 1];
            posts.pop();
        }

        // also delete the post from other mapping as well
        delete allPosts[_id];
        emit PostDeletedEvent(_id);

        
    }

    // This will return index of the post in the array
    function findPostIndex(Post[] storage postsArray, uint postId) internal view returns (uint) {
         for (uint i = 0; i < postsArray.length; i++) {
            if (postsArray[i].id == postId) {
                return i;
            }
        }
        // it will return array if there is no match
        return postsArray.length; 
    }

    //function to get current number of posts
    function getCurrentPostCount() external view returns (uint) {
        return id;
    }

    function writeComments(uint _postID, string memory _content) external onlyUser incrementCommentCounter checkCommentLength(_content) spamControl(_postID) returns (uint, address, string memory, uint) {
        uint _numberOfCharacters = bytes(_content).length;
        Comment memory newComment = Comment(commentsPerPostID, _postID,  msg.sender, _content, _numberOfCharacters);
        comments.push(newComment);
    
        // Update the mapping commentsPerPost
        commentsPerPost[_postID].push(newComment);

        // Update the mapping to mark the user as a comment writer for this post
        commentWritersPerPostIDMapping[_postID][msg.sender] = true;

        // Update the comment count for the post
        commentsCountPerPost[_postID]++;

        // Update the comment count in the Post struct
        allPosts[_postID].commentsPerPostID = commentsCountPerPost[_postID];

        // Update the comment count for the post per genre
        string memory genre = allPosts[_postID].genre;
        uint numberOfCommentsPerPost = commentsCountPerPost[_postID];

        // Update the post in the posts array
       updatePostCommentCount(posts, _postID, numberOfCommentsPerPost);

        // Update the post in the postPerGenre mapping
        updatePostCommentCount(postPerGenre[genre], _postID, numberOfCommentsPerPost);

        emit commentWrittenEvent(_postID, newComment.id);

        return (newComment.id, newComment.userWriter, newComment.content, newComment.numberOfCharacters);
    }


    function updatePostCommentCount(Post[] storage postsArray, uint _postID, uint count) internal {
        uint postIndexToUpdate = findPostIndex(postsArray, _postID);
            if (postIndexToUpdate < postsArray.length) {
                postsArray[postIndexToUpdate].commentsPerPostID = count;
            }
    }

    //function to get number of comments per post
    function getCommentCountPerPost(uint _postID) external view returns (uint) {
        return allPosts[_postID].commentsPerPostID;
    }

    //function to view all posts (both by admin and users --> joint function)
    //needed for the event newPostCreatedEvent
    function getAllPosts() external view returns(Post[] memory){
        return posts;
    }

    //function to view all posts based on genre
    //this one will be called after updating genre, but also can be called after updating title and/or content, we will see
    function getAllPostsPerGenre(string memory _wantedGenre) external view returns(Post[] memory){
        return postPerGenre[_wantedGenre];
    }

    //function to get all comments per post
    //needed for event commentWrittenEvent
    function getCommentsPerPost(uint _postID) external view returns (Comment[] memory){
        return commentsPerPost[_postID];
    }

   
    

}



    










