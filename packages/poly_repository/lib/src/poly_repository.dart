import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolyRepository {
  const PolyRepository();

  List<LatLng> generatePathInsidePolygon(List<LatLng> polygonPoints, double stepM) {
    double minX = polygonPoints.map((e) => e.latitude).reduce(min);
    double maxX = polygonPoints.map((e) => e.latitude).reduce(max);
    double minY = polygonPoints.map((e) => e.longitude).reduce(min);
    double maxY = polygonPoints.map((e) => e.longitude).reduce(max);

    double stepLat = metersToLatitude(stepM);
    double stepLng = metersToLongitude(stepM, (minX + maxX) / 2);

    List<LatLng> path = [];
    bool moveRight = true;

    for (double currentX = minX; currentX <= maxX; currentX += stepLat) {
      if (moveRight) {
        for (double currentY = minY; currentY <= maxY; currentY += stepLng) {
          LatLng point = LatLng(currentX, currentY);
          if (isPointInPolygon(point, polygonPoints)) {
            path.add(point);
          }
        }
      } else {
        for (double currentY = maxY; currentY >= minY; currentY -= stepLng) {
          LatLng point = LatLng(currentX, currentY);
          if (isPointInPolygon(point, polygonPoints)) {
            path.add(point);
          }
        }
      }
      moveRight = !moveRight;
    }

    path = connectPoints(path);

    return path;
  }

  List<LatLng> connectPoints(List<LatLng> points) {
    List<LatLng> connectedPath = [];

    if (points.isEmpty) {
      return connectedPath;
    }

    LatLng previousPoint = points.first;
    connectedPath.add(previousPoint);

    for (int i = 1; i < points.length; i++) {
      LatLng currentPoint = points[i];
      connectedPath.add(currentPoint);
      previousPoint = currentPoint;
    }

    return connectedPath;
  }

  double metersToLatitude(double meters) {
    return meters / 111320;
  }

  double metersToLongitude(double meters, double latitude) {
    double latitudeRadians = latitude * pi / 180;
    return meters / (111320 * cos(latitudeRadians));
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygonPoints) {
    int i, j = polygonPoints.length - 1;
    bool oddNodes = false;

    for (i = 0; i < polygonPoints.length; i++) {
      if (polygonPoints[i].longitude < point.longitude && polygonPoints[j].longitude >= point.longitude ||
          polygonPoints[j].longitude < point.longitude && polygonPoints[i].longitude >= point.longitude) {
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

  double calculatePathLength(List<LatLng> path) {
    double totalLength = 0.0;

    for (int i = 0; i < path.length - 1; i++) {
      LatLng point1 = path[i];
      LatLng point2 = path[i + 1];
      double distance = calculateDistance(point1, point2);
      totalLength += distance;
    }

    return totalLength;
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    // Using Haversine formula to calculate the distance between two points on the Earth's surface
    const double earthRadius = 6371000; // Radius of the Earth in meters
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  /// CALCULATE MOWING TIME
  double calculateMowingTime({
    double mowingSpeedKmh = 3.0, // Default mowing speed in km/h
    double efficiency = 0.8, // Default efficiency factor
    required double pathLength, // Total length of the path in meters
  }) {
    // Convert speed to meters per minute
    double effectiveSpeedMMin = mowingSpeedKmh * (1000 / 60);

    // Calculate time to mow one meter
    double timePerMeterMin = 1 / effectiveSpeedMMin;

    // Calculate total time in minutes
    double totalTimeMin = timePerMeterMin * pathLength * efficiency;

    return totalTimeMin;
  }

  static const double EARTH_RADIUS = 6371000; // meters

  /// CALCULATE SQUARE AREA
  double calculateAreaOfGPSPolygonOnEarthInSquareMeters(List<LatLng> locations) {
    return calculateAreaOfGPSPolygonOnSphereInSquareMeters(locations, EARTH_RADIUS);
  }

  double calculateAreaOfGPSPolygonOnSphereInSquareMeters(List<LatLng> locations, double radius) {
    if (locations.length < 3) {
      return 0;
    }

    final double diameter = radius * 2;
    final double circumference = diameter * pi;
    final List<double> listY = [];
    final List<double> listX = [];
    final List<double> listArea = [];

    // calculate segment x and y in degrees for each point
    final double latitudeRef = locations[0].latitude;
    final double longitudeRef = locations[0].longitude;
    for (int i = 1; i < locations.length; i++) {
      final double latitude = locations[i].latitude;
      final double longitude = locations[i].longitude;
      listY.add(_calculateYSegment(latitudeRef, latitude, circumference));
      listX.add(_calculateXSegment(longitudeRef, longitude, latitude, circumference));
    }

    // calculate areas for each triangle segment
    for (int i = 1; i < listX.length; i++) {
      final double x1 = listX[i - 1];
      final double y1 = listY[i - 1];
      final double x2 = listX[i];
      final double y2 = listY[i];
      listArea.add(_calculateAreaInSquareMeters(x1, x2, y1, y2));
    }

    // sum areas of all triangle segments
    double areasSum = 0;
    for (final area in listArea) {
      areasSum = areasSum + area;
    }

    // get absolute value of area, it can't be negative
    return areasSum.abs();
  }

  double _calculateAreaInSquareMeters(double x1, double x2, double y1, double y2) {
    return (y1 * x2 - x1 * y2) / 2;
  }

  double _calculateYSegment(double latitudeRef, double latitude, double circumference) {
    return (latitude - latitudeRef) * circumference / 360.0;
  }

  double _calculateXSegment(double longitudeRef, double longitude, double latitude, double circumference) {
    double latitudeInRadians = latitude * pi / 180;
    return (longitude - longitudeRef) * circumference * cos(latitudeInRadians) / 360.0;
  }
}
