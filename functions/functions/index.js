const functions = require("firebase-functions");
const {logger} = require("firebase-functions");
const geolib = require("geolib");


exports.generatePathInsidePolygon = functions.https.onRequest(
    (request, response) => {
      try {
        // Ensure we're dealing with a POST request
        if (request.method !== "POST") {
          return response.status(405).send("Method Not Allowed");
        }

        const polygonPoints = request.body.polygonPoints;
        const stepM = request.body.stepM;

        // Validate the input data
        if (!Array.isArray(polygonPoints) || polygonPoints.length < 3 ||
                typeof stepM !== "number") {
          logger.error("Invalid input data");
          return response.status(400).send("Invalid input data");
        }

        // Call the function to generate the path inside the polygon
        const path = generatePathInsidePolygon(polygonPoints, stepM);

        // Respond with the generated path
        response.status(200).json({path});
      } catch (error) {
        logger.error("Error generating path in polygon", error);
        response.status(500).send("Error generating path in polygon");
      }
    });

exports.sayHello = functions.https.onRequest((req, res) => {
  const origin = req.get("Origin");
  const allowedOrigins = [/firebase\.com$/, "flutter.com"];

  // Check if the origin is allowed
  const isAllowed = allowedOrigins.some((allowedOrigin) => {
    return typeof allowedOrigin === "string" ?
            origin === allowedOrigin :
            allowedOrigin.test(origin);
  });

  if (isAllowed) {
    res.set("Access-Control-Allow-Origin", origin);
  }

  res.status(200).send("Hello world!");
});


function generatePathInsidePolygon(polygonPoints, stepM) {
  const minX = Math.min(...polygonPoints.map((p) => p.latitude));
  const maxX = Math.max(...polygonPoints.map((p) => p.latitude));
  const minY = Math.min(...polygonPoints.map((p) => p.longitude));
  const maxY = Math.max(...polygonPoints.map((p) => p.longitude));

  const stepLat = metersToLatitude(stepM);
  const stepLng = metersToLongitude(stepM, (minX + maxX) / 2);

  const path = [];
  let moveRight = true;

  for (let currentX = minX; currentX <= maxX; currentX += stepLat) {
    if (moveRight) {
      for (let currentY = minY; currentY <= maxY; currentY += stepLng) {
        const point = {latitude: currentX, longitude: currentY};
        if (geolib.isPointInside(point, polygonPoints)) {
          path.push(point);
        }
      }
    } else {
      for (let currentY = maxY; currentY >= minY; currentY -= stepLng) {
        const point = {latitude: currentX, longitude: currentY};
        if (geolib.isPointInside(point, polygonPoints)) {
          path.push(point);
        }
      }
    }
    moveRight = !moveRight;
  }

  return connectPoints(path);
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

