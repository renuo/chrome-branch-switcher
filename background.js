chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.branch && request.projectSlug && request.home) {
    fetch('http://localhost:64014/switch-branch', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ branch: request.branch, projectSlug: request.projectSlug, home: request.home })
    }).then(response => response.json())
      .then(data => {
        sendResponse({status: 'success', message: data.message});
      })
      .catch(error => {
        sendResponse({status: 'error', message: error.message});
      });
  }
  return true;
});
