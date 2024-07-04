document.addEventListener('turbo:load',checkPullRequestPage);

function checkPullRequestPage(){
  console.log('Checking pull request page');
  if (window.location.href.match(/pull\/\d+/)) {
    checkHomeDirectory();
  }
}


// Function to check if the home directory is set
function checkHomeDirectory() {
  chrome.storage.local.get('homeDirectory', function(data) {
    if (data.homeDirectory) {
      const projectSlug = getProjectNameFromUrl();
      console.log('Project Name:', projectSlug);
      addSwitchBranchButton(projectSlug, data.homeDirectory);
    } else {
      console.log('Home directory is not set. Please set it in the extension options.');
    }
  });
}

function addSwitchBranchButton(projectSlug, homeDirectory) {
  var buttonText = 'Switch Branch';
  var button = document.createElement('button');
  button.innerHTML = buttonText;
  button.className = 'Button Button--secondary Button--small';
  button.onclick = function() {
    var branchName = document.querySelector('.commit-ref.head-ref').innerText.trim();
    chrome.runtime.sendMessage({branch: branchName, projectSlug: projectSlug, home: homeDirectory}, (response) => {
      if (response.status === 'success') {
        button.innerHTML = '✔ Switched';
        button.style.backgroundColor = '#28a745';
        setTimeout(() => {
          button.innerHTML = buttonText;
          button.style.backgroundColor = null;
        }, 2000);
      } else {
        button.innerHTML = '❌ Error';
        button.style.backgroundColor = '#d73a49';
        setTimeout(() => {
          button.innerHTML = buttonText;
          button.style.backgroundColor = null;
        }, 2000);
      }
    });
  };
  document.querySelector('.gh-header-meta').appendChild(button);
}

function getProjectNameFromUrl() {
  const pathParts = window.location.pathname.split('/');
  if (pathParts.length >= 3) {
    return pathParts[2];
  }
  return null;
}
