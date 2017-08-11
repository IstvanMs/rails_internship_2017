class CompaniesController < ApplicationController
  before_action :authenticate_user, :only => [:show, :edit, :new ]

  def new
    @company = Company.new
    @user = User.new
  end

  def show
    @company = Company.find(params[:id])
    @user = User.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to @company
    else
      render 'new'
    end
  end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])

    if @company.update(company_params)
      redirect_to @company
    else
      render 'edit'
    end
  end

  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    redirect_to root_path
  end

  private
  def company_params
    params.require(:company).permit(:name)
  end

end
