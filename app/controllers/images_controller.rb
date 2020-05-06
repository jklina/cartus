class ImagesController < ApplicationController
  def create
    @images = Image.create!(images_params) { |image|
      image.imageable = current_user
    }
    respond_to do |format|
      format.json { render json: @images }
    end
  end

  private

  def images_params
    params.permit(images: [:description, :image]).require(:images)
  end
end
