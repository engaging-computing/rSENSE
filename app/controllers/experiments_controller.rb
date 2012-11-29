class ExperimentsController < ApplicationController
  # GET /experiments
  # GET /experiments.json
  skip_before_filter :authorize, only: [:show,:index]  
    
  def index

    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    @featured_3 = Experiment.where(featured: true).order("updated_at DESC").limit(3);
    
    @experiments = Experiment.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 8).order("created_at #{sort}")

    @experiments.each do |e|
       e['owner'] = User.find(e.user_id) 
    end
    
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show
    @experiment = Experiment.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @experiment }
    end
  end

  # GET /experiments/new
  # GET /experiments/new.json
  def new
    @experiment = Experiment.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @experiment }
    end
  end

  # GET /experiments/1/edit
  def edit
    @experiment = Experiment.find(params[:id])
  end

  # POST /experiments
  # POST /experiments.json
  def create
    #@experiment = Experiment.new(params[:experiment])
		
		if(params[:experiment_id])
			@tmp_exp = Experiment.find(params[:experiment_id])
			@experiment = Experiment.new({user_id: @cur_user.id, title:"#{@tmp_exp.title} (clone)", content: @tmp_exp.content, filter: @tmp_exp.filter})
			success = @experiment.save
			@tmp_exp.fields.all.each do |f|
				Field.create({experiment_id:@experiment.id, field_type: f.field_type, name: f.name, unit: f.unit})
			end
		else
			@experiment = Experiment.new({user_id: @cur_user.id, title:"#{@cur_user.firstname} #{@cur_user.lastname[0].pluralize} Experiment"})
			success = @experiment.save
		end

		respond_to do |format|
      if success
        format.html { redirect_to @experiment, notice: 'Experiment was successfully created.' }
        format.json { render json: @experiment, status: :created, location: @experiment }
      else
        format.html { render action: "new" }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /experiments/1s
  # PUT /experiments/1.json
  def update
    @experiment = Experiment.find(params[:id])

    respond_to do |format|
      if @experiment.update_attributes(params[:experiment])
        format.html { redirect_to @experiment, notice: 'Experiment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.json
  def destroy
    @experiment = Experiment.find(params[:id])
    @experiment.destroy

    respond_to do |format|
      format.html { redirect_to experiments_url }
      format.json { head :no_content }
    end
  end
end
