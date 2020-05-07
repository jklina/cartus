class ImagesController < ApplicationController
  def create
    @image = current_user.images.build(image_params)
    if @image.save
      render json: @image
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  private

  def image_params
    params.require(:image).permit(:description, :image, :title)
  end
end
