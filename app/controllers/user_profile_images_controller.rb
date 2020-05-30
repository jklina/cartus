class UserProfileImagesController < ApplicationController
  def create
    @image = current_user.images.build(image_params)
    @image.imageable = current_user
    if @image.save
      render json: @image
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  def destroy
    image = current_user.images.find(params[:id])
    if image.destroy
      head :no_content
    else
      render json: image.errors, status: :unprocessable_entity
    end
  end

  private

  def image_params
    params.require(:image).permit(:description, :image, :title)
  end
end
