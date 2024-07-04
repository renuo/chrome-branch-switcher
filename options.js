document.addEventListener('DOMContentLoaded', function() {
  const homeDirectoryInput = document.getElementById('homeDirectory');
  const saveButton = document.getElementById('saveButton');

  // Load the stored home directory
  chrome.storage.local.get('homeDirectory', function(data) {
    if (data.homeDirectory) {
      homeDirectoryInput.value = data.homeDirectory;
    }
  });

  // Save the home directory when the save button is clicked
  saveButton.addEventListener('click', function() {
    const homeDirectory = homeDirectoryInput.value.trim();
    if (homeDirectory) {
      chrome.storage.local.set({ homeDirectory: homeDirectory }, function() {
        alert('Home directory saved');
      });
    }
  });
});
