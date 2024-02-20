const functions = require("firebase-functions");
const turf = require("turf/turf");

exports.generatePathInsidePolygon = functions.https.onRequest((
    request, response) => {
  // Ensure that the request is a POST request
  if (request.method !== "POST") {
    return response.status(405).send("Method Not Allowed");
  }

  const polygonCoordinates = request.body.polygon;
  const mowerWidth = request.body.mowerWidth;

  if (!polygonCoordinates || !Array.isArray(polygonCoordinates) ||
    polygonCoordinates.length === 0) {
    return response.status(400).send("Invalid polygon coordinates");
  }
  if (!mowerWidth || typeof mowerWidth !== "number" || mowerWidth <= 0) {
    return response.status(400).send("Invalid mower width");
  }

  // Create a Turf.js polygon
  const lawnPolygon = turf.polygon([polygonCoordinates]);

  // Create a grid of points to represent potential path points
  const pointsGrid = turf.pointGrid(turf.bbox(lawnPolygon),
      mowerWidth, {units: "meters"});

  // Filter the points to only those that are inside the lawn polygon
  const pointsInside = turf.pointsWithinPolygon(pointsGrid, lawnPolygon);

  // Convert the points to a path
  let pathCoordinates = [];
  pointsInside.features.forEach((point, index) => {
    pathCoordinates.push(point.geometry.coordinates);
  });

  // Sort the path coordinates in a boustrophedon pattern
  pathCoordinates = sortBoustrophedon(pathCoordinates);

  // Return the path as a GeoJSON LineString
  const pathGeoJSON = turf.lineString(pathCoordinates);

  // Send the generated path back in the response
  response.status(200).send(pathGeoJSON);
});

// Function to sort path coordinates in a boustrophedon pattern
function sortBoustrophedon(coordinates) {
  const sortedCoordinates = [];
  coordinates.forEach((coord, index) => {
    if (index % 2 === 0) {
      // For even-indexed coordinates, keep them as they are
      sortedCoordinates.push(coord);
    } else {
      // For odd-indexed coordinates, reverse their order
      sortedCoordinates.push(coord.reverse());
    }
  });
  return sortedCoordinates;
}
