import express from 'express';
import multer from 'multer';
import { createApi } from 'unsplash-js';
import fetch from 'node-fetch';

const unsplash = createApi({
  accessKey: 'https://api.unsplash.com/search/photos?query=nature&client_id=5KjXvLFCssyevod_93JmskGHRiOpQKqzdt61MyoiZnA', // Replace with your Unsplash access key
  fetch: fetch,
});

const app = express();
const port = 3000;

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // Destination folder for uploaded files
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname); // Unique filename for uploaded files
  }
});

const upload = multer({ storage: storage });

console.log("Server is starting..."); // Log a message indicating that the server is starting

// Route for uploading images from the gallery
app.post('/api/upload', upload.single('image'), async (req, res) => {
  try {
    console.log("Received POST request for image upload"); // Log a message when a POST request is received

    if (!req.file) {
      console.log("No file uploaded"); // Log a message when no file is uploaded
      return res.status(400).json({ error: 'No file uploaded' });
    }

    // Assuming the file path is saved in req.file.path
    const imagePath = req.file.path;
    console.log("Uploaded image path:", imagePath); // Log the path to the uploaded image

    // Fetch random images from Unsplash API
    const imageData = await fetchUnsplashImages();
    console.log("Fetched images:", imageData); // Log the fetched image data

    // Return the uploaded image path and fetched image data as JSON response
    res.json({
      uploadedImagePath: imagePath,
      fetchedImages: imageData
    });
  } catch (error) {
    console.error('Error uploading image:', error); // Log any errors that occur during image upload
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to handle GET requests for the root URL
app.get('/', (req, res) => {
  res.send('Hello, world!'); // Send a simple response for GET requests to the root URL
});

// Function to fetch random images from Unsplash API
async function fetchUnsplashImages() {
  try {
    const response = await unsplash.photos.getRandomPhoto({ count: 10 });
    const jsonData = await response.json();
    return jsonData.map(photo => photo.urls.regular);
  } catch (error) {
    console.error('Error fetching images from Unsplash:', error);
    return [];
  }
}

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`); // Log a message indicating that the server is running and listening on the specified port
});
