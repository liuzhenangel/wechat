$(document).on('turbolinks:load', ()=>{
  makeQrcodeImage('#qrcode-image');
});

function makeQrcodeImage(id) {
  let image_container = $(id);
  if( image_container.length > 0 ){
    image_container.empty();
    let text = image_container.data('url');
    let width = image_container.data('width') || 256;
    let height = width;
    new QRCode( image_container[0], { text: text, width: width, height: height } );
  }
};
