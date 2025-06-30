package com.example.receipt_scanner_plugin;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.io.File;
import java.util.ArrayList;

public class ReceiptScannerPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private TextRecognizer recognizer;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "receipt_scanner_plugin");
    channel.setMethodCallHandler(this);
    recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "isAvailable":
        result.success(true); // ML Kit is available on Android
        break;
      case "scanImage":
        String imagePath = call.argument("imagePath");
        if (imagePath != null) {
          scanImageWithMLKit(imagePath, result);
        } else {
          result.error("INVALID_ARGUMENTS", "Image path is required", null);
        }
        break;
      case "scanDocument":
        result.error("UNSUPPORTED", "Document scanner is only available on iOS", null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void scanImageWithMLKit(String imagePath, Result result) {
    try {
      File imageFile = new File(imagePath);
      Bitmap bitmap = BitmapFactory.decodeFile(imageFile.getAbsolutePath());
      InputImage image = InputImage.fromBitmap(bitmap, 0);

      recognizer.process(image)
        .addOnSuccessListener(new OnSuccessListener<Text>() {
          @Override
          public void onSuccess(Text visionText) {
            result.success(visionText.getText());
          }
        })
        .addOnFailureListener(new OnFailureListener() {
          @Override
          public void onFailure(@NonNull Exception e) {
            result.error("ML_KIT_ERROR", e.getMessage(), null);
          }
        });
    } catch (Exception e) {
      result.error("IMAGE_ERROR", e.getMessage(), null);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    if (recognizer != null) {
      recognizer.close();
    }
  }
}