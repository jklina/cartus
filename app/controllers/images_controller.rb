class ImagesController < ApplicationController
  def create
    @image = current_user.images.build(image_params)
    @image.save
    respond_to do |format|
      format.json { render json: @image }
    end
  end

  private

  def image_params
    params.require(:image).permit(:description, :image, :title)
  end
end
