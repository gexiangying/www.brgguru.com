<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>队伍管理</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			 <div data-role="content">
				<form action="teams.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<% if not tour_no then  %>
						<li data-role="fieldcontain">
							<label for="tour_no">比赛ID</label>
							<input type="text" name="tour_no" id="tour_no">
						</li>
						<% else %>
						<input type="hidden" name="tour_no" value="<%=tour_no %>"/>
						<% end %>
            <li data-role="fieldcontain">
							<label for="no">队伍编号</label>
							<input type="number" name="no" id="no">
						</li>
						<li data-role="fieldcontain">
							<label for="name">姓名:</label>
								<select name="name" id="name" >
									<option value="张扬队">张杨队</option>
									<option value="牛狼队">牛狼队</option>
									<option value="大连大学">大连大学</option>
									<option value="台山队">台山队</option>
									<option value="人民银行">人民银行</option>
									<option value="大连桥协">大连桥协</option>
									<option value="大连澳新">大连澳新</option>
									<option value="笑联队">笑联队</option>
									<option value="大连地产">大连地产</option>
									<option value="大连人保">大连人保</option>
								</select>
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
			<% 
     
		 local db = {}																		 
																					 
     if tour_no and no and name then
		 db = tour.load_admin(tour_no) or {}																		 
     db.team = db.team or {}																					 
       local index = _G.tonumber(no)
       db.team[index] = db.team[index] or {}																					 
       db.team[index].no = index																					 
       db.team[index].name = name 
     tour.save_admin(tour_no,db)
     end
		 %>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >编号</th>
							<th >队伍名称</th>
						</tr>
					</thead>
					<tbody>
						<% db.team = db.team or {} %>
						<% for i,v in _G.ipairs(db.team) do %>
						<tr>
							<td><%=v.no %></td>
							<td><%=v.name %></td>
						</tr>
						<% end %>
          </tbody>
				</table>
			</div>
		</div>
	</body>
</html>

