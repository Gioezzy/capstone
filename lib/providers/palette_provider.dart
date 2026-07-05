import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

// Provides a list of dominant colors extracted from an image URL.
final paletteProvider = FutureProvider.family<List<Color>, String>((ref, imageUrl) async {
  ImageProvider imageProvider;
  
  if (imageUrl.startsWith('http')) {
    imageProvider = NetworkImage(imageUrl);
  } else {
    imageProvider = AssetImage(imageUrl);
  }

  final paletteGenerator = await PaletteGenerator.fromImageProvider(
    imageProvider,
    maximumColorCount: 10,
  );

  final List<Color> colors = [];
  
  // Extract key colors in order of preference
  if (paletteGenerator.dominantColor != null) {
    colors.add(paletteGenerator.dominantColor!.color);
  }
  if (paletteGenerator.vibrantColor != null) {
    colors.add(paletteGenerator.vibrantColor!.color);
  }
  if (paletteGenerator.mutedColor != null) {
    colors.add(paletteGenerator.mutedColor!.color);
  }
  if (paletteGenerator.darkVibrantColor != null) {
    colors.add(paletteGenerator.darkVibrantColor!.color);
  }
  if (paletteGenerator.lightVibrantColor != null) {
    colors.add(paletteGenerator.lightVibrantColor!.color);
  }

  // Ensure unique colors
  return colors.toSet().toList();
});
