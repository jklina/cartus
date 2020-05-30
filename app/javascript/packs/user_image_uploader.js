// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.
// It will render "Hello Elm!" within the page.

import { Elm } from '../ElmComponents/UserImageUploader/Main'

document.addEventListener('DOMContentLoaded', () => {
  const containerClass = ".user-image-uploader";
  const target = document.querySelector(containerClass);
  const profileImage = target.dataset.profileImage;
  console.log(profileImage)
  Elm.ElmComponents.UserImageUploader.Main.init({ node: target, flags: profileImage });
})
