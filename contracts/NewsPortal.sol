// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

//NAPOMENA: Razdvojiti  komentare po postu (valjda smo to uradile)
//NAPOMENA: //MOZDA MOZE OVAKO KAKO SAM KRENULA za positions

contract NewsPortal {

    struct Post {
        uint id;
        string genre;
        string title;
        string content;
        //Comment[] comments;  //this could not be used because Solidity does not support convesrion between memory and storage data types
        uint commentsPerPostID;
    }

    struct Comment {
        uint id;
        uint postID;
        address userWriter;
        string content;
        uint numberOfCharacters; //this is the length of the comment
        uint numberOfLikes;
        uint numberOfDislikes;
    }

    address private writer; //this is the one and only admin
    address private usersAddress; //used to save users address from mapping, into a variable, so that user can be also deleted from users array

    uint private id = 0; //ID, that will be used to count number of posts and increment for each new post, we started with 1, because that is more natural
    uint private commentsPerPostID = 0; //number of comments per post
    uint private userID = 1; //counter to count the number of users, we started with 1, because that is more natural

    mapping(uint => Post) allPosts; // used to store all posts, key: postID, value: Post struct
    mapping(string => Post[]) postPerGenre; //used to store posts per genre, key:genre, value:arrays of post structs
    mapping(address => string) positions; //so that we know what menu to open //MOZDA MOZE OVAKO KAKO SAM KRENULA
    mapping(uint => address) allUsers; //so that admin can manage all users, key: counter (no. of logged in user), value: user's address
    mapping(uint => Comment[]) commentsPerPost; //key:post ID, value:array of comment structs
    mapping(uint => uint) commentsCountPerPost;
    mapping(string => mapping(uint => uint)) commentsCountPerPostPerGenre; // Updated mapping to include the comment count in each post per genre
    mapping(uint => mapping(address => bool)) commentWritersPerPostIDMapping;  //key: post ID, value: another mapping(user's address => T/F), depending if they commented or not

    Post[] posts;  //list of all posts 
    Comment[] comments; //list of all comments 

    address[] users; //list of all users to view because mapping allUsers is not iterable
    address[] commentWritersPerPostArray; //? ne znam za sta je ovo

    event newPostCreatedEvent(uint id, string genre, string title, string content);
    event postTitleUpdatedEvent(uint id, string newTitle);
    event postContentUpdatedEvent(uint id, string newContent);
    event postGenreUpdatedEvent(uint id, string newGenre);
    event likeCommentAddedEvent(uint postID, uint commentID, uint numberOfLikes);
    event dislikeCommentAddedEvent(uint postID, uint commentID, uint numberOfDislikes);
    event commentWrittenEvent(uint postID, uint commentID);
    event userAddedEvent(address indexed userAddress, string position);
    event userDeletedEvent(address indexed userAddress);


    //modifiers to increment and decrement number of posts and users, and to increment number of comments

    modifier incrementPostCounter(){  
        _;
        id += 1;
    }

    modifier decrementPostCounter(){
        _;
        id -= 1;
    }

    modifier incrementUserCount(){
        _;
        userID += 1;
    }

    modifier decrementUserCount(){
        _;
        userID -= 1;
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

    //modifier to see if the user already logged in one, 
    //if it did, don't memorize its data multiple times

    modifier userNotExists(address _addr) {
        require(bytes(positions[_addr]).length == 0, "User already exists in positions mapping");
        require(allUsers[userID] != _addr, "User already exists in allUsers mapping");
        require(!userExistsInArray(_addr), "User already exists in users array");
        _;
    }

    function userExistsInArray(address _addr) internal view returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    constructor(){
        writer = msg.sender; //this is the one and only admin
        positions[msg.sender] = "Administrator";
    }

    //function to write posts by an admin
    function writePosts(string memory _genre, string memory _title, string memory _content) external incrementPostCounter onlyAdmin {

        // First comment is written by the owner
        /*string memory firstComment = "Thank you for reading my post. Feel free to leave a comment.";  //--> da li nam ovo uopce sad treba
        Comment memory writerComment = Comment( commentsPerPostID, id,  msg.sender, firstComment, 74, 0, 0);
        comments.push(writerComment);

        //each post struct will have a count of its comments
        uint numberOfCommentsPerPost = comments.length;*/

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


    //Functions to update post, by one of the three main features and emit an event for that
    function updateTitle(uint _id, string memory _newTitle) external onlyAdmin{
        allPosts[_id].title = _newTitle;
        uint allPostsIndexToUpdate = findPostIndex(posts, _id);

        // If the post is found in the array, update its title
        if (allPostsIndexToUpdate < posts.length) {
            posts[allPostsIndexToUpdate].title = _newTitle;
        }

        // Find the index of the post in the array based on its genre
        string memory extractGenre = allPosts[_id].genre;
        uint genreIndexToUpdate = findPostIndex(postPerGenre[extractGenre], _id);

        // If the post is found in the genre array, update its title
        if (genreIndexToUpdate < postPerGenre[extractGenre].length) {
            postPerGenre[extractGenre][genreIndexToUpdate].title = _newTitle;
        }

        emit postTitleUpdatedEvent(_id, _newTitle);
    }

    // Function to update post content, it follows the same procedure as the function to update title
    function updateContent(uint _id, string memory _newContent) external onlyAdmin {
        allPosts[_id].content = _newContent;

        uint allPostsIndexToUpdate = findPostIndex(posts, _id);

        // If the post is found in the array, update its content
        if (allPostsIndexToUpdate < posts.length) {
            posts[allPostsIndexToUpdate].content = _newContent;
        }

        // Find the index of the post in the array based on its genre
        string memory extractGenre = allPosts[_id].genre;
        uint genreIndexToUpdate = findPostIndex(postPerGenre[extractGenre], _id);

        // If the post is found in the genre array, update its content
        if (genreIndexToUpdate < postPerGenre[extractGenre].length) {
            postPerGenre[extractGenre][genreIndexToUpdate].content = _newContent;
        }

        emit postContentUpdatedEvent(_id, _newContent);
    }

    //Function to update post genre, it follows the same procedure as the function to update title and content
    function updateGenre(uint _id, string memory _newGenre) external onlyAdmin {
        allPosts[_id].genre = _newGenre;

        uint allPostsIndexToUpdate = findPostIndex(posts, _id);

        // If the post is found in the array, update its content
        if (allPostsIndexToUpdate < posts.length) {
            posts[allPostsIndexToUpdate].genre = _newGenre;
        }

        // Find the index of the post in the array based on its genre
        string memory extractGenre = allPosts[_id].genre;

        uint genreIndexToUpdate = findPostIndex(postPerGenre[extractGenre], _id);

        // If the post is found in the genre array, update its genre
        if (genreIndexToUpdate < postPerGenre[extractGenre].length) {
            postPerGenre[extractGenre][genreIndexToUpdate].genre = _newGenre;
        }

        emit postGenreUpdatedEvent(_id, _newGenre);
    }

    //function to get current number of posts
    function getCurrentPostCount() external view returns (uint) {
        return id;
    }

       function writeComments(uint _postID, string memory _content) external onlyUser incrementCommentCounter checkCommentLength(_content) spamControl(_postID) returns (uint, address, string memory, uint, uint, uint) {
        uint _numberOfCharacters = bytes(_content).length;
        Comment memory newComment = Comment(commentsPerPostID, _postID,  msg.sender, _content, _numberOfCharacters, 0, 0);
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

        return (newComment.id, newComment.userWriter, newComment.content, newComment.numberOfCharacters, newComment.numberOfLikes, newComment.numberOfDislikes);
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

    // function to like a comment
    function likeComment(uint _postID, uint _commentID) external onlyUser returns (uint) {
        // we need to ensure that the comment actually exists
        require(_commentID < comments.length, "Invalid comment ID");
        comments[_commentID].numberOfLikes += 1;

        // also, update the feature of comments in the mapping commentsPerPost
        uint postId = comments[_commentID].postID;
        commentsPerPost[postId][_commentID].numberOfLikes += 1;

        emit likeCommentAddedEvent(_postID, _commentID, comments[_commentID].numberOfLikes);
    
        return comments[_commentID].numberOfLikes;
    }   

    // function to dislike a comment
    function dislikeComment(uint _postID, uint _commentID) external onlyUser returns (uint) {
        require(_commentID < comments.length, "Invalid comment ID");
        comments[_commentID].numberOfLikes += 1;

        uint postId = comments[_commentID].postID;
        commentsPerPost[postId][_commentID].numberOfDislikes += 1;

        emit likeCommentAddedEvent(_postID, _commentID, comments[_commentID].numberOfDislikes);
    
        return comments[_commentID].numberOfLikes;
    }   

    // function to add a user, so we know their address but also for admin to see a list of them
    //user has to be added to all places from where it will be called
    function addAUser(address _addr) external incrementUserCount userNotExists(_addr) {
        allUsers[userID] = _addr;
        users.push(_addr);
        positions[_addr] = "User";
        emit userAddedEvent(_addr, "User");
    }

    

    //Deleting users based on address because that is unique
    function deleteUser(address _userAddress) external onlyAdmin decrementUserCount {
        // Find the index of the user in the array
        uint indexToDelete = findUserIndex(users, _userAddress);

        // If the user is found in the array, remove it
        if (indexToDelete < users.length) {
            // Swap the user to delete with the last user in the array
            users[indexToDelete] = users[users.length - 1];
            // Remove the last element from the array
            users.pop();
        emit userDeletedEvent(_userAddress);
        }

        // Remove the user from the mapping
        delete positions[_userAddress];
        // also delete it from the mapping
        delete allUsers[userID];
}

    // Function to find the index of a user in an array
    function findUserIndex(address[] storage usersArray, address userAddress) internal view returns (uint) {
        for (uint i = 0; i < usersArray.length; i++) {
            if (usersArray[i] == userAddress) {
                return i;
            }
        }
        return usersArray.length; // Return array length if not found
    }

    //functions to getAll to be called after refreshing, getAll is needed after every event

    //function to view all posts (both by admin and users --> joint function)
    //to be called after updating title and/or content, we will see
    //needed for the event newPostCreatedEvent
    function getAllPosts() external view returns(Post[] memory){
        return posts;
    }

    /*I think that for these three events:
    1.postTitleUpdatedEvent
    2.postContentUpdatedEvent
    3.postGenreUpdatedEvent
    we can use both function getAllPosts, and getAllPostsByGenre, but we will see based on frontend implementation*/

    //function to view all posts based on genre
    //this one will be called after updating genre, but also can be called after updating title and/or content, we will see
    function getAllPostsPerGenre(string memory _wantedGenre) external view returns(Post[] memory){
        return postPerGenre[_wantedGenre];
    }

    //View all users
    //needed for these two events, userAddedEvent and userDeletedEvent
    function getAllUsers() external view onlyAdmin returns (address[] memory) {
        return users; //for this, we needed to have that array users[]
    }

    //function to get all comments per post
    //needed for event commentWrittenEvent
    function getCommentsPerPost(uint _postID) external view returns (Comment[] memory){
        return commentsPerPost[_postID];
    }

    // I guesss that these two events can be put together for each comment,  likeCommentAddedEvent and dislikeCommentAddedEvent
    function getNumberOfLikesAndDislikesPerComment(uint _postID, uint _commentID) external view returns (uint, uint) {
        require(_postID < posts.length, "Invalid post ID"); //postID has to be less than or equal because we put by default that the post ID starts from one
        require(_commentID < commentsPerPost[_postID].length, "Invalid comment ID");

        Comment memory comment = commentsPerPost[_postID][_commentID];
        return (comment.numberOfLikes, comment.numberOfDislikes);
    }

}

    










