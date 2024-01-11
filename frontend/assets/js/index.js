var ChangeTab = {
  goToHome: function () {
    $("#HeroDiv").show();
    $("#LifestyleDiv, #TechDiv, #adminDiv,  #NewsDiv").hide();
  },
  goToLifestyle: function () {
    $("#LifestyleDiv").show();
    $("#HeroDiv, #TechDiv, #adminDiv,  #NewsDiv").hide();
  },
  goToTech: function () {
    $("#TechDiv").show();
    $("#LifestyleDiv, #HeroDiv, #adminDiv, #NewsDiv").hide();
  },
  goToAdminPanel: function () {
    $("#adminDiv").show();
    $("#TechDiv, #LifestyleDiv, #HeroDiv, #NewsDiv").hide();
  },
  goToNews: function () {
    $("#NewsDiv").show();
    $("#TechDiv, #LifestyleDiv, #HeroDiv, #adminDiv").hide();
  }
};

const abi = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"}],"name":"PostDeletedEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"helpDeskItemID","type":"uint256"},{"indexed":false,"internalType":"string","name":"topic","type":"string"},{"indexed":false,"internalType":"string","name":"content","type":"string"}],"name":"helpDeskItemWrittenEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"_newAdminAddress","type":"address"}],"name":"newAdminAddedEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"},{"indexed":false,"internalType":"string","name":"genre","type":"string"},{"indexed":false,"internalType":"string","name":"title","type":"string"},{"indexed":false,"internalType":"string","name":"content","type":"string"}],"name":"newPostCreatedEvent","type":"event"},{"inputs":[{"internalType":"address","name":"newAdmin","type":"address"}],"name":"addAdmin","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_id","type":"uint256"}],"name":"deletePost","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getAllPosts","outputs":[{"components":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"string","name":"genre","type":"string"},{"internalType":"string","name":"title","type":"string"},{"internalType":"string","name":"content","type":"string"}],"internalType":"struct NewsPortal.Post[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_wantedGenre","type":"string"}],"name":"getAllPostsPerGenre","outputs":[{"components":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"string","name":"genre","type":"string"},{"internalType":"string","name":"title","type":"string"},{"internalType":"string","name":"content","type":"string"}],"internalType":"struct NewsPortal.Post[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getCurrentPostCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_topic","type":"string"},{"internalType":"string","name":"_content","type":"string"}],"name":"writeHelpDeskItem","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"_genre","type":"string"},{"internalType":"string","name":"_title","type":"string"},{"internalType":"string","name":"_content","type":"string"}],"name":"writePosts","outputs":[],"stateMutability":"nonpayable","type":"function"}];

$(document).ready(function () {
    $('#header, #footer, #HeroDiv, #LifestyleDiv, #TechDiv, #adminDiv, #NewsDiv').hide();
    // Show the login section by default
    $('#LoginDiv').show(); 

    //Function to be called after clicking on the LOGIN button
    $('#connect').click(async function () {
    if (window.ethereum) {   
    let addresses = await window.ethereum.request({ method: 'eth_requestAccounts' });
    //console.log(addresses[0]);
    window.web3 = new Web3(window.ethereum);
    deployed_contract = '0xDc53a9B2BceEfF5e177E44b4A25179abD86C1Dbb'; 

    const contract = new web3.eth.Contract(abi, deployed_contract);
    const adminAddress = "0x4A6D300C16fDbEc06AD04Bf56f79C69B82F7e191"; // Admin 1
    const lowerCaseAdminAddress = adminAddress.toLowerCase();

    const adminAddress2 = "0xBFfB885Ee9adeF105Ced97e74577606eF1a85284"; // Admin 2
    const lowerCaseAdminAddress2 = adminAddress2.toLowerCase();

    // Used to show the address, for user
    $('#connectedAddress > span').html(addresses[0]);
    $('#connect').hide();
    $('#LoginDiv').hide();
    $('#header, #footer, #HeroDiv').show();

    if (addresses[0] === lowerCaseAdminAddress || addresses[0] === lowerCaseAdminAddress2) {
        $('#postCountDisplay').show(); 
        $('postCount').show(); 
        $('#writePostBtn').show();
        $('#deletePostBtn').show();
        $('#addANewAdmin').show();
        displayPostsByGenre('Lifestyle'); 
        displayPostsByGenre2('Tech'); 
        getAllPosts();
        updatePostCount(); 

    //Function to display Lifestyle posts in its genre
    async function displayPostsByGenre(genre) {
        let posts = await contract.methods.getAllPostsPerGenre(genre).call();
        let postsContainer = $('#genrePostsContainer');
        postsContainer.empty();
        posts.forEach((post, index) => {
            let postId = 'post_' + index;
            let postCard = `
            <div class="card" id="${postId}">
                <div class="card-header">${post.genre}</div>
                    <div class="card-body">
                    <h5 class="card-title">${post.title}</h5>
                    <button class="btn btn-primary read-more-btn">Read More</button>
                </div>
            </div>
        `;

        postsContainer.append(postCard);

        $('#' + postId + ' .read-more-btn').click(function() {
            // Hide the short version of the card, and open a bigger version
            $('#' + postId).hide();

            // Show the detailed post content
            $('#detailedPost').html(`
                <div class="row">
                    <div class="col-lg-6 order-1 order-lg-2">
                    <img src="./assets/img/about-img.jpg" class="img-fluid" alt="">
                    </div>
                    <div class="col-lg-6 pt-4 pt-lg-0 order-2 order-lg-1">
                    <h3>${post.title}</h3>
                    <p>${post.content}</p>
                    <button class="btn btn-primary back-btn">Back</button>
                    </div>
                </div>
            `).show();
            
            // Back button functionality
            $('.back-btn').click(function() {
                $('#detailedPost').hide();
                $('#' + postId).show();
            });
        });
    });
    }

    //Function to display Tech posts in its genre
    async function displayPostsByGenre2(genre) {
    let posts = await contract.methods.getAllPostsPerGenre(genre).call();
    
    let postsContainer = $('#genrePostsContainer2');
    postsContainer.empty();

    posts.forEach((post, index) => {
        let postId = 'post_' + index;
        let postCard = `
            <div class="card" id="${postId}">
              <div class="card-header">${post.genre}</div>
              <div class="card-body">
                <h5 class="card-title">${post.title}</h5>
                <button class="btn btn-primary read-more-btn">Read More</button>
              </div>
            </div>
        `;

        postsContainer.append(postCard);

        $('#' + postId + ' .read-more-btn').click(function() {
            // Hide the short version of post, and show the longer one
            $('#' + postId).hide();

            // Show the detailed post content
            $('#detailedPost2').html(`
                <div class="row">
                    <div class="col-lg-6 order-1 order-lg-2">
                    <img src="./assets/img/about-img.jpg" class="img-fluid" alt="">
                    </div>
                    <div class="col-lg-6 pt-4 pt-lg-0 order-2 order-lg-1">
                    <h3>${post.title}</h3>
                    <p>${post.content}</p>
                    <button class="btn btn-primary back-btn">Back</button>
                    </div>
                </div>
            `).show();

            // Back button functionality
            $('.back-btn').click(function() {
                $('#detailedPost2').hide();
                $('#' + postId).show();
            });
        });
    });
    }

    //Functionalites that address what happens when you click on these two menu buttons
    $('#lifestyleButton').click(function() {
        displayPostsByGenre('Lifestyle');
    });

    $('#techButton').click(function() {
        displayPostsByGenre2('Tech');
    });


    $('#writePostBtn').click(function () {
        // Show the write post modal to admin
        $('#writePosts').show();
        $('#postsList').hide();
        $('#writePostBtn').hide();
    });

    // Handle submit post button click
    $('#submitPost').click(async function () {
        const genre = $('#genre').val();
        const title = $('#title').val();
        const content = $('#content').val();

        try {
            await contract.methods.writePosts(genre, title, content).send({ from: addresses[0] }).then(function (result) {
                alert('Post created successfully!');
                $('#genre').val(''); 
                $('#title').val(''); 
                $('#content').val(''); 
                
             });
        } catch (error) {
            console.error("Error creating post:", error);
        }
    });

    //Event that will happen after successfully submitting a new post
    contract.events.newPostCreatedEvent()
        .on('data', function (event) {
        console.log("New post created: ", event);
        $('#writePosts').hide();
        $('#postsList').show();
        $('#writePostBtn').show();
        $('#deletePostBtn').show();
        $('#addANewAdmin').show();
        getAllPosts();
        updatePostCount(); 
        displayPostsByGenre(event.returnValues.genre); //This will return updated blog posts for genre Lifestyle
        displayPostsByGenre2(event.returnValues.genre); //This will return updated blog posts for genre Tech
    });

    $('#cancelPost').click(function (event) { 
        //I had to add event here as a parameter, otherwise would not work
        event.preventDefault(); 
        $('#title').val(''); 
        $('#genre').val(''); 
        $('#content').val(''); 
        $('#writePosts').hide();
        $('#postsList').show();
        $('#writePostBtn').show();
        getAllPosts();
    });

    //Function needed to list all posts
    async function getAllPosts() {
        let addresses = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const contract = new web3.eth.Contract(abi, deployed_contract);
        let posts = await contract.methods.getAllPosts().call({ from: addresses[0] });

        let tableContent = '';

        for (let i = 0; i < posts.length; i++) {
            tableContent += `
                <tr>
                    <td>${posts[i].id}</td>
                    <td>${posts[i].title}</td>
                    <td>${posts[i].genre}</td>
                </tr>
            `;
        }

        $('#postTableBody').html(tableContent);  // Update the content of the postTableBody
    }

    //Functionality to open the modal to delete a post
    $('#deletePostBtn').click(function () {
        // Show the delete post modal
        $('#deletePostModal').show();
        $('#postsList').hide();
        $('#deletePostBtn').hide();
    });

    $('#confirmDelete').click(async function () {
        let postIdToDelete = $('#deletePostID').val();
        let parsedPostIdToDelete = parseInt(postIdToDelete, 10);
        console.log("Post ID to delete:", parsedPostIdToDelete); //debugging code

        try {
            let posts = await contract.methods.getAllPosts().call({ from: addresses[0] });
            let maxPostId = Math.max(...posts.map(post => parseInt(post.id, 10)));

            if (isNaN(parsedPostIdToDelete) || parsedPostIdToDelete > maxPostId) {
                alert('Invalid Post ID: Entered ID is invalid or does not exist.');
                return;
            }

            await contract.methods.deletePost(parsedPostIdToDelete).send({ from: addresses[0] })
            .then(function (result) {
                alert('Post deleted successfully!');
                // Refresh the post list if needed
                //getAllPosts();
                //here nothing is needed, because event will take care of this post action
            });
        } catch (error) {
            console.error("Error deleting post:", error);
            alert('Failed to delete post. Error: ' + error.message);
        }

        // Hide the modal after deleting
        $('#deletePostModal').hide(); 
    });


    $('#cancelDelete').click(function () {
        // Hide the modal and clear the input field
        $('#deletePostID').val('');
        $('#deletePostModal').hide();
        $('#postsList').show();
        $('#deletePostBtn').show();
        $('#addANewAdmin').show();
    });

    contract.events.PostDeletedEvent()
        .on('data', function (event) {
        console.log("Post deleted: ", event);
        $('#postsList').show();
        getAllPosts();
        updatePostCount();
        $('#writePostBtn').show();
        $('#deletePostBtn').show();
        $('#addANewAdmin').show();
        displayPostsByGenre(event.returnValues.genre); //This will return updated blog posts for genre Lifestyle
        displayPostsByGenre2(event.returnValues.genre); //This will return updated blog posts for genre Tech
    });

    async function deletePost(postId) {
        try {
            await contract.methods.deletePost(postId).send({ from: addresses[0] })
            .then(function (result) {
                alert('Post deleted successfully!');
                //getAllPosts();
            });
        } catch (error) {
            console.error("Error deleting post:", error);
            alert('Failed to delete post.');
        }
    }   

    async function updatePostCount() {
        try {
            let postCount = await contract.methods.getCurrentPostCount().call({ from: addresses[0] });
            $('#postCount').text(postCount);
        } catch (error) {
            console.error("Error fetching post count:", error);
        }
    } 

    // Show the add admin post modal
    $('#addANewAdmin').click(function () {
        $('#addANewAdminModal').show();
        $('#postsList').hide();
        $('#addANewAdmin').hide();
    });

    //Functions to add a new admin
    $('#confirmNewAdmin').click(async function () {
    const newAdmin = $('#adminAddress').val();
        try {
            await contract.methods.addAdmin(newAdmin).send({ from: addresses[0] }).then(function (result) {
                alert('New Admin added successfully!');      
            });
        } catch (error) {
            console.error("Error while adding a new admin:", error);
        }
        $('#addANewAdminModal').hide(); 
    });

    $('#cancelNewAdmin').click(function () {
        // Hide the modal and clear the input field
        $('#adminAddress').val('');
        $('#addANewAdminModal').hide();
        $('#postsList').show();
        $('#deletePostBtn').show();
        $('#addANewAdmin').show();
    });

    contract.events.newAdminAddedEvent()
        .on('data', function (event) {
        console.log("New Admin added: ", event);
        $('#postsList').show();
        getAllPosts();
        $('#writePostBtn').show();
        $('#deletePostBtn').show();
        $('#addANewAdmin').show();
    });

} 
//END FOR ADMIN Functionalities

else{
    // For regular users, show user content
    $('#admin').hide();
    $('#postCountDisplay').hide();
    $('postCount').hide(); 
    $('#userDiv').show();
    $('#genrePostsContainer').show();
    $('#connectedAddress').show();
    $('#connectedAddress > span').html(addresses);
    $('#writeHelpDeskItem').show();
        
    //Function to display Lifestyle posts in its genre
    async function displayPostsByGenre(genre) {
        let posts = await contract.methods.getAllPostsPerGenre(genre).call();
        let postsContainer = $('#genrePostsContainer');
        postsContainer.empty();
        posts.forEach((post, index) => {
            let postId = 'post_' + index;
            let postCard = `
            <div class="card" id="${postId}">
                <div class="card-header">${post.genre}</div>
                    <div class="card-body">
                    <h5 class="card-title">${post.title}</h5>
                    <button class="btn btn-primary read-more-btn">Read More</button>
                </div>
            </div>
        `;

        postsContainer.append(postCard);

        $('#' + postId + ' .read-more-btn').click(function() {
            // Hide the short version of the card, and open a bigger version
            $('#' + postId).hide();

             // Show the detailed post content
             $('#detailedPost').html(`
             <div class="row">
                 <div class="col-lg-6 order-1 order-lg-2">
                 <img src="./assets/img/about-img.jpg" class="img-fluid" alt="">
                 </div>
                 <div class="col-lg-6 pt-4 pt-lg-0 order-2 order-lg-1">
                 <h3>${post.title}</h3>
                 <p>${post.content}</p>
                 <button class="btn btn-primary back-btn">Back</button>
                 </div>
             </div>
         `).show();
            
            // Back button functionality
            $('.back-btn').click(function() {
                $('#detailedPost').hide();
                $('#' + postId).show();
            });
        });
    });
    }

    //Function to display Tech posts in its genre
    async function displayPostsByGenre2(genre) {
        let posts = await contract.methods.getAllPostsPerGenre(genre).call();
    
        let postsContainer = $('#genrePostsContainer2');
        postsContainer.empty();

        posts.forEach((post, index) => {
        let postId = 'post_' + index;
        let postCard = `
            <div class="card" id="${postId}">
              <div class="card-header">${post.genre}</div>
              <div class="card-body">
                <h5 class="card-title">${post.title}</h5>
                <button class="btn btn-primary read-more-btn">Read More</button>
              </div>
            </div>
        `;

        postsContainer.append(postCard);
    
        $('#' + postId + ' .read-more-btn').click(function() {
            // Hide the short version of post, and show the longer one
            $('#' + postId).hide();

            // Show the detailed post content
            $('#detailedPost2').html(`
                <div class="row">
                    <div class="col-lg-6 order-1 order-lg-2">
                    <img src="./assets/img/about-img.jpg" class="img-fluid" alt="">
                    </div>
                    <div class="col-lg-6 pt-4 pt-lg-0 order-2 order-lg-1">
                    <h3>${post.title}</h3>
                    <p>${post.content}</p>
                    <button class="btn btn-primary back-btn">Back</button>
                    </div>
                </div>
            `).show();

            // Back button functionality
            $('.back-btn').click(function() {
                $('#detailedPost2').hide();
                $('#' + postId).show();
            });
        });
    });
    }

    //Functionalites that address what happens when you click on these two menu buttons
    $('#lifestyleButton').click(function() {
        displayPostsByGenre('Lifestyle');
    });

    $('#techButton').click(function() {
        displayPostsByGenre2('Tech');
    });
}

    //Event when new help desk item is submitted
    contract.events.helpDeskItemWrittenEvent()
        .on('data', function (event) {
        console.log("New help desk item created: ", event);
        $('#topic').val(''); 
        $('#contentOfProblem').val('');
    });


    // Functio to submit a new help desk item
    $('#submitRequest').click(async function () {
        const topic = $('#topic').val();
        const contentOfProblem = $('#contentOfProblem').val();

        if (contentOfProblem.length > 250 ) {
            alert('Problem description is too long. Please provide a shorter description.');
            return;
        }

        try {
            await contract.methods.writeHelpDeskItem(topic, contentOfProblem).send({ from: addresses[0] }).then(function (result) {
                alert('Your request has been successfully sent!');
                //now, event continues
                });
        } catch (error) {
            console.error("Error while submitting the rquest:", error);
        }
    });

    $('#cancelRequest').click(function (event) {
        event.preventDefault(); 
        $('#topic').val(''); 
        $('#contentOfProblem').val('');
    });

    }}
)});




