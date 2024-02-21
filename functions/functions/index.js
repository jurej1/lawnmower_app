const functions = require("firebase-functions");

class LatLng {
  constructor(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }
}

exports.generatePathInsidePolygon = functions.https.onRequest((
    request, response) => {
  // Enable CORS using the `cors` module, or manually set HTTP headers
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "GET, POST");

  // Check for POST request
  if (request.method !== "POST") {
    response.status(405).send("Method Not Allowed");
    return;
  }

  // Parse the request body to get the polygon points and stepM
  const polygonPoints = request.body.polygonPoints.map(
      (p) => new LatLng(p.lat, p.lng));
  const stepM = request.body.stepM;

  // Validate the input
  if (!polygonPoints || !stepM) {
    response.status(400).send("Bad Request: Missing polygonPoints or stepM");
    return;
  }

  // Call the function to generate the path
  const path = generatePathInsidePolygon(polygonPoints, stepM);

  // Send the generated path as a response
  response.status(200).json(path);
});


function generatePathInsidePolygon(polygonPoints, stepM) {
  const minX = Math.min(...polygonPoints.map((p) => p.latitude));
  const maxX = Math.max(...polygonPoints.map((p) => p.latitude));
  const minY = Math.min(...polygonPoints.map((p) => p.longitude));
  const maxY = Math.max(...polygonPoints.map((p) => p.longitude));

  const stepLat = metersToLatitude(stepM);
  const stepLng = metersToLongitude(stepM, (minX + maxX) / 2);

  let path = [];
  let moveRight = true;

  for (let currentX = minX; currentX <= maxX; currentX += stepLat) {
    if (moveRight) {
      for (let currentY = minY; currentY <= maxY; currentY += stepLng) {
        const point = new LatLng(currentX, currentY);
        if (isPointInPolygon(point, polygonPoints)) {
          path.push(point);
        }
      }
    } else {
      for (let currentY = maxY; currentY >= minY; currentY -= stepLng) {
        const point = new LatLng(currentX, currentY);
        if (isPointInPolygon(point, polygonPoints)) {
          path.push(point);
        }
      }
    }
    moveRight = !moveRight;
  }

  path = connectPoints(path);

  return path;
}

function connectPoints(points) {
  const connectedPath = [];

  if (points.length === 0) {
    return connectedPath;
  }

  let previousPoint = points[0];
  connectedPath.push(previousPoint);

  for (let i = 1; i < points.length; i++) {
    const currentPoint = points[i];
    connectedPath.push(currentPoint);
    previousPoint = currentPoint;
  }

  return connectedPath;
}

function metersToLatitude(meters) {
  return meters / 111320;
}

function metersToLongitude(meters, latitude) {
  const latitudeRadians = latitude * Math.PI / 180;
  return meters / (111320 * Math.cos(latitudeRadians));
}

function isPointInPolygon(point, polygonPoints) {
  let i; let j = polygonPoints.length - 1;
  let oddNodes = false;

  for (i = 0; i < polygonPoints.length; i++) {
    if ((polygonPoints[i].longitude < point.longitude &&
      polygonPoints[j].longitude >= point.longitude) ||
      (polygonPoints[j].longitude < point.longitude &&
        polygonPoints[i].longitude >= point.longitude)) {
      if (polygonPoints[i].latitude +
        (point.longitude - polygonPoints[i].longitude) /
        (polygonPoints[j].longitude - polygonPoints[i].longitude) *
        (polygonPoints[j].latitude - polygonPoints[i].latitude) <
        point.latitude) {
        oddNodes = !oddNodes;
      }
    }
    j = i;
  }

  return oddNodes;
}

