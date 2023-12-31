const path = require('path');
const sass = require('sass');
const fs = require('fs');
const imageType = require('image-type');

const RangeStyle = {
  VERSION: 2.2,

  DIR: {
    raw: path.join('!style', 'range'),
    out: path.join('docs', 'dat.style', 'range'),
    img: path.join('!style', 'range', 'img')
  },

  STYLES: {
    apl: ['current', 'classic', 'sommar', 'summer'],
    ptp: ['current'],
    it: ['current'],
    what: ['current', 'classic', 'sommar', 'summer']
  },

  version() {
    return this.VERSION;
  },

  styles() {
    return this.STYLES;
  },

  compile(compressed) {
    this.compressed = !!compressed;

    const min = compressed ? ".min" : "";

    const range = {
      base: this.render('range')
    };

    for (const [site, styles] of Object.entries(this.STYLES)) {
      console.log(site);
      range.site = this.render('__site_' + site);

      for (const style of styles) {
        range.style = this.render('__style_' + style);

        ['wide', 'slim'].forEach(size => {
          range.size = this.render('__size_' + size);
          Write(range, path.join(this.DIR.out, `${site}.${style}.${size}${min}.css`));
        });
      }
    }

    // Write(range, path.join(this.DIR.out, `test.css`));

  },

  render(file) {
    const options = {
      file: path.join('.', this.DIR.raw, `${file}.scss`),
      outputStyle: this.compressed ? 'compressed' : 'expanded',
      sourceMap: true,
    };
    const css = sass.renderSync(options).css.toString();
    return this.compressed ? B64(css) : css;
    // return B64(css);
  }

};

const Write = (sassEngines, filepath) => {
  console.log('Writing: ' + filepath);
  const output = Object.values(sassEngines).join('');
  fs.writeFileSync(filepath, output);
}

const B64 = (cssString) => {

  const memoizedImages = new Map();

  function getImageBase64(imagePath) {
    if (memoizedImages.has(imagePath)) {
      return memoizedImages.get(imagePath);
    }

    try {
      const imageData = fs.readFileSync('./' + imagePath);
      const type = imageType(imageData);
      const base64Data = imageData.toString('base64');
      const base64Url = `data:${type.mime};base64,${base64Data}`;
      memoizedImages.set(imagePath, base64Url);
      return base64Url;
    } catch (error) {
      console.error('Error encoding image:', error);
      return null;
    }
  }

  const convert = () => {
    const regex = /url\(['"]?\/dat\.style\/range\/i(.+?\.(png|svg|jpg|jpeg|gif))['"]?\)/g;

    const matches = [...cssString.matchAll(regex)];

    // console.log(matches.length);

    for (const match of matches) {
      const imagePath = RangeStyle.DIR.img + match[1]; // Group 1 contains the image path
      // console.log('relpath', imagePath)
      const base64Url = getImageBase64(imagePath);
      if (base64Url) {
        cssString = cssString.replace(match[0], `url(${base64Url})`);
      }
    }

    return cssString;
  }

  return convert();
}

module.exports = RangeStyle;