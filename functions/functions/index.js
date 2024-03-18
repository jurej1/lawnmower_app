// Importiere das Firebase-Funktionen-Modul, um Cloud-Funktionen zu erstellen
const functions = require("firebase-functions");
// Importiere das Geolib-Modul für geographische Berechnungen
const geolib = require("geolib");
// Importiere das Firebase-Admin-Modul zur Verwaltung der Firebase-Ressourcen
const admin = require("firebase-admin");
// Initialisiere die Firebase-App
admin.initializeApp();

// Definiere eine Klasse für Breiten- und Längengrad
class LatLng {
  constructor(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }
}

// Definition einer HTTP-Cloud-Funktion
exports.generatePathInsidePolygon = functions.https.onRequest((request, response) => {
  response.set("Access-Control-Allow-Origin", "*"); // Erlaube CORS für alle Domains
  response.set("Access-Control-Allow-Methods", "GET, POST"); // Erlaube GET und POST

  if (request.method !== "POST") { // Nur POST erlauben, sonst Fehler senden
    response.status(405).send("Method Not Allowed");
    return;
  }

  // Polygonpunkte aus Anfrage extrahieren und umwandeln
  const polygonPoints = request.body.polygonPoints.map(
    (p) => new LatLng(p.lat, p.lng));
  const stepM = request.body.stepM; // Schrittweite extrahieren

  if (!polygonPoints || !stepM) { // Prüfe auf fehlende Daten und sende Fehler
    response.status(400).send("Bad Request: Missing polygonPoints or stepM");
    return;
  }

  // Pfad innerhalb des Polygons generieren
  const path = generatePathInsidePolygon(polygonPoints, stepM);

  response.status(200).json(path); // Generierten Pfad als JSON senden
});


// Definiere eine Funktion, um einen Pfad innerhalb eines Polygons zu generieren
function generatePathInsidePolygon(polygonPoints, stepM) {
  // Finde die minimale und maximale Breite der Polygonpunkte
  const minX = Math.min(...polygonPoints.map((p) => p.latitude));
  const maxX = Math.max(...polygonPoints.map((p) => p.latitude));
  // Finde die minimale und maximale Länge der Polygonpunkte
  const minY = Math.min(...polygonPoints.map((p) => p.longitude));
  const maxY = Math.max(...polygonPoints.map((p) => p.longitude));

  // Konvertiere die Schrittweite von Metern in Breitengrade
  const stepLat = metersToLatitude(stepM);
  // Konvertiere die Schrittweite von Metern in Längengrade, basierend auf der
  // durchschnittlichen Breite
  const stepLng = metersToLongitude(stepM, (minX + maxX) / 2);

  // Initialisiere ein leeres Array für den Pfad
  const path = [];
  // Initialisiere eine Variable, um die Bewegungsrichtung zu bestimmen
  let moveRight = true;

  // Schleife durch die Breitengrade innerhalb der Grenzen des Polygons
  for (let currentX = minX; currentX <= maxX; currentX += stepLat) {
    // Wenn die Bewegungsrichtung nach rechts ist, schleife durch die Längengrade
    if (moveRight) {
      for (let currentY = minY; currentY <= maxY; currentY += stepLng) {
        // Erstelle einen neuen Punkt
        const point = new LatLng(currentX, currentY);
        // Überprüfe, ob der Punkt im Polygon liegt und füge ihn zum Pfad hinzu
        if (isPointInPolygon(point, polygonPoints)) {
          path.push(point);
        }
      }
    } else {
      // Wenn die Bewegungsrichtung nach links ist, schleife rückwärts durch die Längengrade
      for (let currentY = maxY; currentY >= minY; currentY -= stepLng) {
        // Erstelle einen neuen Punkt
        const point = new LatLng(currentX, currentY);
        // Überprüfe, ob der Punkt im Polygon liegt und füge ihn zum Pfad hinzu
        if (isPointInPolygon(point, polygonPoints)) {
          path.push(point);
        }
      }
    }
    // Wechsle die Bewegungsrichtung für den nächsten Durchlauf
    moveRight = !moveRight;
  }

  // Gebe den generierten Pfad zurück
  return path;
}



// Umrechnung von Metern in Breitengrade
function metersToLatitude(meters) {
  return meters / 111320;
}

// Umrechnung von Metern in Längengrade (abhängig von Breite)
function metersToLongitude(meters, latitude) {
  const latitudeRadians = latitude * Math.PI / 180;
  return meters / (111320 * Math.cos(latitudeRadians));
}

// Prüfung, ob Punkt im Polygon liegt
function isPointInPolygon(point, polygonPoints) {
  return geolib.isPointInPolygon(
    {latitude: point.latitude, longitude: point.longitude},
    polygonPoints.map((p) => ({latitude: p.latitude, longitude: p.longitude})),
  );
}




