// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.
// It will render "Hello Elm!" within the page.

import { Elm } from '../ElmComponents/PostForm/Main'

document.addEventListener('DOMContentLoaded', () => {
  const containerClass = "post-form";
  const targets = document.getElementsByClassName(containerClass);
  for (let target of targets) {
      // const previewImage = target.dataset.previewImage;
      Elm.ElmComponents.PostForm.Main.init({ node: target });
  }
})
