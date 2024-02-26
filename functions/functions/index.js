const functions = require("firebase-functions");
const geolib = require("geolib");
const admin = require("firebase-admin");
admin.initializeApp();

class LatLng {
  constructor(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }
}

exports.generatePathInsidePolygon = functions.https.onRequest((
    request, response) => {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "GET, POST");


  if (request.method !== "POST") {
    response.status(405).send("Method Not Allowed");
    return;
  }


  const polygonPoints = request.body.polygonPoints.map(
      (p) => new LatLng(p.lat, p.lng));
  const stepM = request.body.stepM;


  if (!polygonPoints || !stepM) {
    response.status(400).send("Bad Request: Missing polygonPoints or stepM");
    return;
  }


  const path = generatePathInsidePolygon(polygonPoints, stepM);


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
  return geolib.isPointInPolygon(
      {latitude: point.latitude, longitude: point.longitude},
      polygonPoints.map((p) =>
        ({latitude: p.latitude, longitude: p.longitude})),
  );
}


exports.calculateAreaOfGPSPolygon = functions.https.onRequest(
    (request, response) => {
    // Enable CORS using the `cors` express middleware.
      const cors = require("cors")({origin: true});
      cors(request, response, () => {
        if (request.method !== "POST") {
          return response.status(405).send("Method Not Allowed");
        }

        const locations = request.body.locations;
        const radius = request.body.radius;

        if (!locations || locations.length < 3 || !radius) {
          return response.status(400).send("Invalid input");
        }

        const area = calculateAreaOfGPSPolygonOnSphereInSquareMeters(
            locations,
            radius,
        );
        response.status(200).send({area: area});
      });
    });

function calculateAreaOfGPSPolygonOnSphereInSquareMeters(locations, radius) {
  if (locations.length < 3) {
    return 0;
  }

  const diameter = radius * 2;
  const circumference = diameter * Math.PI;
  const listY = [];
  const listX = [];
  const listArea = [];

  // calculate segment x and y in degrees for each point
  const latitudeRef = locations[0].latitude;
  const longitudeRef = locations[0].longitude;
  for (let i = 1; i < locations.length; i++) {
    const latitude = locations[i].latitude;
    const longitude = locations[i].longitude;
    listY.push(calculateYSegment(latitudeRef, latitude, circumference));
    listX.push(calculateXSegment(longitudeRef, longitude, latitude,
        circumference));
  }

  // calculate areas for each triangle segment
  for (let i = 1; i < listX.length; i++) {
    const x1 = listX[i - 1];
    const y1 = listY[i - 1];
    const x2 = listX[i];
    const y2 = listY[i];
    listArea.push(calculateAreaInSquareMeters(x1, x2, y1, y2));
  }

  // sum areas of all triangle segments
  let areasSum = 0;
  listArea.forEach((area) => {
    areasSum += area;
  });

  // get absolute value of area, it can't be negative
  return Math.abs(areasSum);
}

function calculateAreaInSquareMeters(x1, x2, y1, y2) {
  return (y1 * x2 - x1 * y2) / 2;
}

function calculateYSegment(latitudeRef, latitude, circumference) {
  return (latitude - latitudeRef) * circumference / 360.0;
}

function calculateXSegment(longitudeRef, longitude, latitude, circumference) {
  const latitudeInRadians = latitude * Math.PI / 180;
  return (longitude - longitudeRef) * circumference *
    Math.cos(latitudeInRadians) / 360.0;
}
