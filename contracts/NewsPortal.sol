// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract NewsPortal {

    struct Post {
        uint id;
        string genre;
        string title;
        string content;
    }

    struct HelpDeskItem {
        uint id;
        string topic;
        string content;
    }

    uint private id = 1;                     //ID value for posts, we started with one because it feels more natural
    uint private helpDeskItemID = 1;         //ID value for help desk items, we started with one because it feels more natural
    uint private postCounter = 0;            //counter for number of posts

    mapping(uint => Post) allPosts;          // used to store all posts, key: postID, value: Post struct
    mapping(string => Post[]) postPerGenre;  //used to store posts per genre, key:genre, value:arrays of post structs
    mapping(address => bool) private admins; //we have two admins

    Post[] posts;                            //array of all post struct items
    HelpDeskItem[] helpDeskService;          //array of all help desk struct items

    event newPostCreatedEvent(uint id, string genre, string title, string content);
    event helpDeskItemWrittenEvent(uint helpDeskItemID, string topic, string content);
    event PostDeletedEvent(uint id);
    event newAdminAddedEvent(address _newAdminAddress);
    
    //modifiers to increment and decrement post counter; increment post and help desk item ID

    modifier incrementPostCounter(){  
        _;
        postCounter += 1;
    }

    modifier incrementPostID(){
        _;
        id += 1;
    }

    modifier decrementPostCounter(){
        _;
        postCounter -= 1;
    }

        modifier incrementhelpDeskItemID(){
        _;
        helpDeskItemID += 1;
    }

    //modifiers to limit access control, one for admin, and one for user
    modifier onlyUser(){
        require( admins[msg.sender] == false, "You have to be logged in as a user for this.");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only an admin can perform this action.");
        _;
    }

    //modifier to check  character limit
    modifier checkLength(string memory textToBeTested) {
        require(bytes(textToBeTested).length <= 250, "You went over character limit of 250!");
        _;
    }

    constructor() {
        admins[msg.sender] = true; 
    }

    //Function to add another admin
    function addAdmin(address newAdmin) external onlyAdmin {
        admins[newAdmin] = true;
        emit newAdminAddedEvent(newAdmin); 
    }

    //Function to write posts by an admin
    function writePosts(string memory _genre, string memory _title, string memory _content) external incrementPostCounter incrementPostID onlyAdmin {

        // Create a new Post 
        Post memory newPost = Post(id, _genre, _title, _content);
        posts.push(newPost);

        //We also need to add new post to both mappings that are related to post structs
        postPerGenre[_genre].push(newPost);
        allPosts[id] = newPost;

        //Emit an event that the new post is created
        emit newPostCreatedEvent(id, _genre, _title, _content);
    }

    //Function to delete posts by an admin
    //Posts need to be deleted in 3 seperate places, two mappings and one array
    function deletePost(uint _id) external onlyAdmin decrementPostCounter {
        string memory extractGenre = allPosts[_id].genre;

        //First, we found index of the post to delete
        uint indexToDelete = findPostIndex(postPerGenre[extractGenre], _id);

        //If the post is in right array, by finding  the right genre, then delete it
        if (indexToDelete < postPerGenre[extractGenre].length) {
            //We also swapped positions of the last item in the array and the one we want to delete
            postPerGenre[extractGenre][indexToDelete] = postPerGenre[extractGenre][postPerGenre[extractGenre].length - 1];
            postPerGenre[extractGenre].pop();
        }

        //Post needs to be deleted as well  from posts, which is an array of structs
        //Same procedure as above will be followed
        uint postsIndexToDelete = findPostIndex(posts, _id);

        if (postsIndexToDelete < posts.length) {
            posts[postsIndexToDelete] = posts[posts.length - 1];
            posts.pop();
        }

        //Also delete the post from other mapping
        delete allPosts[_id];
        emit PostDeletedEvent(_id);

        
    }

    //This will return index of the post in the array
    //Needed as an internal function to delete the post from the posts array
    function findPostIndex(Post[] storage postsArray, uint postId) internal view returns (uint) {
         for (uint i = 0; i < postsArray.length; i++) {
            if (postsArray[i].id == postId) {
                return i;
            }
        }
        //It will return array if there is no match
        return postsArray.length; 
    }

    //Function to get current number of posts
    //Also, it will be called fter event to write and delete posts
    function getCurrentPostCount() external onlyAdmin view returns (uint) {
        return postCounter;
    }

    //Function to view all posts
    //Needed for the event newPostCreatedEvent
    function getAllPosts() external onlyAdmin view returns(Post[] memory){
        return posts;
    }

    //Function to write help desk item by a user
    function writeHelpDeskItem(string memory _topic, string memory _content) external  incrementhelpDeskItemID  checkLength(_content) onlyUser {

        // Create a new help desk item 
        HelpDeskItem memory newItem = HelpDeskItem(helpDeskItemID, _topic, _content);
        helpDeskService.push(newItem);

        //Emit an event that the new post is created
        emit helpDeskItemWrittenEvent(helpDeskItemID, _topic, _content);
    }

    //Function to view all posts based on genre
    //This one will be called after updating genre
    function getAllPostsPerGenre(string memory _wantedGenre) external view returns(Post[] memory){
        return postPerGenre[_wantedGenre];
    }



   
    

}



    










