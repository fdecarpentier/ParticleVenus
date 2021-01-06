//Macro by Félix de Carpentier, 2021, CNRS / Sorbonne University / Paris-Saclay University, France

setOption("ExpandableArrays", true);
setOption("ScaleConversions", true);
setBackgroundColor(255, 255, 255);
setBatchMode(true);

//Choose directories
input_path=getDirectory("Choose input folder");
output_path=getDirectory("Choose output folder for the results");

//Init. variables
list_full=getFileList(input_path);
list_type=newArray("c1", "c2") //can be changed according to your file naming system
list_sample=newArray;
list_last=newArray;
j=0;
currentNResults=0; 

//Create the list of individual samples using list_type[0] file name
for(i=0; i<list_full.length; i++) {
	file_last=lastIndexOf(list_full[i], "_");
	list_last[i] = substring(list_full[i], file_last, lengthOf(list_full[i]));
	name=substring(list_full[i], 0, file_last);
	if(endsWith(name, list_type[0]) == 1) {
		list_sample[j]=substring(name, 0, lastIndexOf(name, "_"));
		j++;
	}
}

//Process images
for(i=0; i<list_sample.length; i++) {
	//Open the different images from one sample
	for(j=0; j<list_type.length; j++) {
		name=list_sample[i]+"_"+list_type[j];
		open(input_path+name+list_last[i+j]);
		rename(name);
	}

	//Set new names for the windows that allows an easy-to-read code
	venus_name = list_sample[i]+"_"+list_type[0];
	chloro_name = list_sample[i]+"_"+list_type[1];

	//Fill here the actions to make with the different images
	duplicate(chloro_name, "_dupli");
	duplicate(chloro_name, "_dupli2");
	get_threshold(chloro_name, 10, "Default dark");
	get_threshold(venus_name, 5, "Li dark");
	get_ROI(chloro_name);
	transfer_label(chloro_name+"_dupli", chloro_name+"_chloro", "blue");
	add_result(chloro_name, currentNResults);
	currentNResults=nResults; //Save the number of the last result
	clear_outside(venus_name, chloro_name);
	get_ROI(venus_name);
	transfer_label(chloro_name+"_dupli2", chloro_name+"_venus", "blue");
	add_result(venus_name, currentNResults);
	roiManager("Delete"); //Clear the ROI manager
	currentNResults=nResults; //Save the number of the last result
	close("*");
}
setOption("ShowRowNumbers", false); 
saveAs("results", output_path+"results.csv"); 
close_win("ROI Manager");
close_win("Threshold");
close_win("Log");
close_win("Results"); 
close_win("Processed");
setBatchMode(false);

//Functions
function duplicate(win_name, sufix) {
	selectWindow(win_name);
	run("Duplicate...", " ");
	rename(win_name+sufix);
}

function get_threshold(img_name, blur, method) {
	selectWindow(img_name);
	//run("8-bit");
	if(blur!=0) run("Gaussian Blur...", "sigma="+blur); //Blur the particles to select the objects and not the sub-objects
	setAutoThreshold(method);
	run("Convert to Mask");
	//run("Fill Holes");
}

function get_ROI(img_name) {
	selectWindow(img_name);
	run("Set Measurements...", "area redirect=None decimal=4");
	run("Analyze Particles...", "size=0-Infinity add display");
}

function clear_outside(win_name, ref_name) {
	selectWindow(win_name);
	roiManager("Show All without labels");
	if(roiManager("count") > 1) {
		roiManager("Combine");
		run("Clear Outside");
	} 
	if(roiManager("count") == 1) {
		run("Select All");
		run("Clear Outside");
	}
	roiManager("Show None");
	run("Select All");
	roiManager("Delete"); //Clear the ROI manager
}

function transfer_label (win_name, save_name, color) {
	selectWindow(win_name);
	roiManager("Set Color", color); 
	roiManager("Show All without labels");
	run("Flatten");
	saveAs("Jpeg", output_path+save_name+".jpg");
	close(win_name);
}

function add_result(win_name, first_row) {
	for (row = first_row; row < nResults; row++) 
	{
		setResult("Image", row, win_name);
	}
	updateResults();
	print(win_name);
}

function close_win (win_name) {
	if (isOpen(win_name)) {
		selectWindow(win_name);
		run("Close");
	}
}