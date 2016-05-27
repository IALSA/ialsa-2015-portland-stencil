Thanks @beccav8, @raquelgraham, @bpmulligan.  We read and appreciated all your comments.  (@andkov is running errands for the party tonight, but I'm sure he'll respond later by himself.)  Thank you again for attending yesterday and givin us valuable & thoughtful perspectives.

@beccav8:
> I can see where users can get confused if they are unfamiliar with R. There was a lot more shuffling around through the rstudio environment.

Good points, and I hope that the real workshops will have a more polished & cohesive presentation fo the scripts.  I'm guessing that the real workshops won't cover the code as much as yesterday.  The plan is to have much of that occur behind the scenes (and some before the conference) so that they don't have to be aware of the code between the PCS and the transcriber.

Ideally the PCS is completed several weeks before the conference (which means everything until the transcriber is run on our servers, instead of their laptops).  We asked you guys to complete the PCS the morning of, so we could better gauge its usability.  I'm glad we did, because you guys gave helpful suggestions that we hadn't anticipated (like presenting fewer survey pages to facilitate `ctrl+F` searching).

>Perhaps a drop down menu where the user could select the variables they have in their data, and then only respond to questions on these variables would be simpler (if possible)? Alternatively, including all the cognitive variables on the same page as discussed could allow the user to search (cntr. F) for their variables. Or, based on the study they select on page 1, perhaps only variables we know are available to them would appear?

It's funny, we had this initially, but thought it was too overwhelming.  So we broke it into pages (which in hindsight was a mistake) and removed the initial checkboxes, which enabled something like your suggestion "and then only respond to questions on these variables".  Based on the checkboxes, textboxes were shown for only their variables.  (In a small mock-up, @Maleeha produced this effect with item-specific branching logic).  However in the end, we felt the checkboxes unnecessarily doubled the amount of items, and increased the chances of incorrect/inconsistent repsonses.  The user still had to go through each variable (and the checkbox stage), and then had to to the textboxes for all the checked variables.

If you have other ideas besides checkboxes, please tell @andkov in person, or share them here.

>Providing future users with a guideline (like what was written on the bored) would be useful.

That would be nice, and we should definitely do that.  I'm almost afraid to ask @andkov what diagram he's planning to assist the participant along the future workshop's journey and dawn of discovery.

@bpmulligan:
> Particularly, it was complicated by the fact that I was running a very minimized OS that did not have a lot of basic software packages that would be found on a typical install of Linux. Although I could run R and RStudio without issue, my system was not equipped to run the packages required by the "stencil" scripts. I like Will's suggestion of creating a system-check/package installation script for folks to run before arriving at the workshop.

Yeah, I'm glad you brought the use case to our attention, and we definitely should be more explicit about what they need to have installed & operational on their laptop before they leave their school and get on the plane.  Everything works on my Linux laptop, but I've been running these programs for months on it, and the cost of misbehaving packages has been acceptably amortized.  We need to prevent them coming to the workshop with a fresh & untested laptop, regardless of the OS.  Also, I think requiring an operational  M*plus* installation will filter out some of these cases.

I wanted to address/regurgitate two more great suggestions of yours.

Providing a virtualized desktops (on a server that UVic/IALSA manages) could drastically reduce the variability of people's setup.  As @andkov pointed out, some investigators would be allowed to put their PHI on another school's server.  But for the others investigators, life would be a lot easier.  It would also be cheaper, if they don't have M*plus* licenses.

UVic/IALSA could maintain the VM in between workshops, but keep it off most of the time (and save costs).  Similarly, this could be hosted on [Amazon EC2 server](https://aws.amazon.com/ec2/).  As I showed after the workshop officially ended, I've had a lot of success with this arrangement in other situations. (Note to self, an [Amazon Workspace VDI](https://aws.amazon.com/workspaces/) would be unecessarily expensive if each desktop needed an M*plus* license that license was used only ~2 workshops a year.)

We'd need to:

* provide participants with personal accounts
* ensure that the host has enough WiFi bandwidth to facilitate all the virtual/visual traffic between the server and the participants' laptops.
* create an image with R, RStudio, appropriate R packages, and M*plus*.  (Is there anything I'm forgetting?)
