class DitherFloydSteinberg {
  private void ditherDirection(PImage img, PImage after, int y, color [] error, color[] nexterror, int direction) {
    int w = after.width;
    color oldPixel = color(0, 0, 0);
    color newPixel = color(0, 0, 0);
    color quant_error = color(0, 0, 0);
    int start, end, x;

    for (x = 0; x < w; ++x) nexterror[x] = color(0, 0, 0);

    if (direction > 0) {
      start = 0;
      end = w;
    } else {
      start = w - 1;
      end = -1;
    }

    // for each x from left to right
    for (x = start; x != end; x += direction) {
      // oldpixel := pixel[x][y]
      oldPixel = add(img.pixels[y*w+x],error[x]);
      // newpixel := find_closest_palette_color(oldpixel)
      newPixel = quantizeToColor(oldPixel);
      // pixel[x][y] := newpixel
      after.pixels[y*w+x] = newPixel;
      // quant_error := oldpixel - newpixel
      quant_error = sub(oldPixel,newPixel);
      // pixel[x+1][y  ] += 7/16 * quant_error
      // pixel[x-1][y+1] += 3/16 * quant_error
      // pixel[x  ][y+1] += 5/16 * quant_error
      // pixel[x+1][y+1] += 1/16 * quant_error
      nexterror[x] = add(nexterror[x],scale(quant_error,5.0 / 16.0));
      if (x + direction >= 0 && x + direction < w) {
        error[x + direction] = add(error[x + direction],scale(quant_error,7.0 / 16.0));
        nexterror[x + direction] = add(nexterror[x + direction],scale(quant_error,1.0 / 16.0));
      }
      if (x - direction >= 0 && x - direction < w) {
        nexterror[x - direction] = add(nexterror[x - direction], scale(quant_error, 3.0 / 16.0));
      }
    }
  }

  private color scale(color c0,float v) {
    float r = red(c0)*v;
    float g = green(c0)*v;
    float b = blue(c0)*v;
    return color(r,g,b);
  }

  private color add(color c0,color c1) {
    float r = red(c0)+red(c1);
    float g = green(c0)+green(c1);
    float b = blue(c0)+blue(c1);
    return color(r,g,b);
  }

  private color sub(color c0,color c1) {
    float r = red(c0)-red(c1);
    float g = green(c0)-green(c1);
    float b = blue(c0)-blue(c1);
    return color(r,g,b);
  }
  
  public PImage filter(PImage img) {
    int y;
    int h = img.height;
    int w = img.width;
    int direction = 1;
    color[] error = new color[w];
    color[] nexterror = new color[w];

    for (y = 0; y < w; ++y) {
      error[y] = color(0, 0, 0);
      nexterror[y] = color(0, 0, 0);
    }

    PImage after = img.copy();
    
    // for each y from top to bottom
    for (y = 0; y < h; ++y) {
      ditherDirection(img, after, y, error, nexterror, direction);

      direction = -direction;
      color[] tmp = error;
      error = nexterror;
      nexterror = tmp;
    }

    return after;
  }
}
