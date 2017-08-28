class RoleFieldsController < ApplicationController
	before_action :admin_user, :only => [:index, :create, :destroy, :update]
  	before_action :authenticate_user

	def update
		@role_field = RoleField.find(params[:id])
		@role_field.update({:role_id => role_field_params[:role_id], :name => role_field_params[:name].capitalize, :field_type => role_field_params[:field_type], :values => role_field_params[:values], :mandatory => role_field_params[:mandatory]})
  		
		redirect_to role_fields_path(:id => @role_field.role_id)
	end

	def create
		@role_field = RoleField.new({:role_id => role_field_params[:role_id], :name => role_field_params[:name].capitalize, :field_type => role_field_params[:field_type], :values => role_field_params[:values], :mandatory => role_field_params[:mandatory]})
	  	@role_field.save
		
		redirect_to role_fields_path(:id => @role_field.role_id)
	end

	def destroy
		@role_field = RoleField.find(params[:id])
		@role = Role.find(@role_field.role_id)

		@role_field.destroy

		redirect_to role_fields_path(:id => @role.id)
	end

	def index
		if params[:t] == 'edit'
			@role_field = RoleField.find(params[:id])
			@role = Role.find(params[:role])
			@role_fields = RoleField.where(:role_id => @role.id)
		else
			@role_field = RoleField.new
			@role_field.values = { len: 0, values: [] }.to_json
			@role = Role.find(params[:id])
			@role_fields = RoleField.where(:role_id => params[:id])
		end
	end

	private 
    def role_field_params
		params.require(:role_field).permit(:role_id, :name, :field_type, :values, :mandatory)
    end
end
