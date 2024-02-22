const functions = require("firebase-functions");
const geolib = require("geolib");

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
