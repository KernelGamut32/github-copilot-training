<%-- 
    File: legacyDashboard.jsp
    Purpose: Demonstrate a large, messy legacy JSP for refactoring demos.
    Notes:
      - Intentionally uses scriptlets, inline SQL, shared mutable state, and poor separation of concerns.
      - Mixed HTML/CSS/JS/SQL/Java in one file; duplicated code; weak error handling; XSS risks; insecure SQL concatenation.
      - DO NOT use in production. This is a teaching artifact.

    Copilot targets to improve:
      * Extract business logic to Java classes (services/DAOs).
      * Replace scriptlets with JSTL/EL.
      * Parameterize SQL; introduce a connection pool; use try-with-resources.
      * Add proper validation, escaping, and encoding.
      * Introduce MVC (Servlet/Controller -> JSP View).
      * De-duplicate rendering code; split into fragments; use tag files.
--%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"
         import="java.sql.*,java.util.*,java.text.SimpleDateFormat,java.net.URLEncoder" %>
<%@ page isELIgnored="true" %>
<%@ page session="true" %>
<%@ include file="header-fragment-that-does-too-much.jsp" %>
<%-- Old JSTL (declared but barely used) --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%! 
// === GLOBALS (bad) ===
static Connection sharedConn; // thread-unsafe shared mutable state
static Map<Long, String> cache = new HashMap<Long, String>(); // naive cache, never invalidated
static int pageRenderCount = 0; // race condition

// Fake "util" methods inside JSP (bad)
public String formatMoney(double d) {
    try { return "$" + String.format(Locale.US, "%,.2f", d); } catch (Exception e) { return "$" + d; }
}
public String nullOr(String v, String fallback) { return (v == null || v.trim().length()==0) ? fallback : v; }

// Naive connection getter (no pool, no close)
public Connection getConnection() {
    try {
        if(sharedConn == null || sharedConn.isClosed()) {
            Class.forName("com.mysql.jdbc.Driver"); // old driver class
            sharedConn = DriverManager.getConnection("jdbc:mysql://localhost/legacydb?user=root&password=root");
        }
        return sharedConn;
    } catch(Exception e) {
        e.printStackTrace();
        return null;
    }
}

// Very unsafe "escape" (not really)
public String html(String s){ return s == null ? "" : s.replace("<","&lt;"); }

// Duplicate HTML-building logic (should be a tag or JSTL loop)
public String renderUserRow(long id, String name, String email, String role, double balance, Date createdAt) {
    String created = (new SimpleDateFormat("yyyy-MM-dd")).format(createdAt);
    return "<tr>" +
           "<td>"+id+"</td>" +
           "<td>"+name+"</td>" +
           "<td>"+email+"</td>" +
           "<td>"+role+"</td>" +
           "<td>"+formatMoney(balance)+"</td>" +
           "<td>"+created+"</td>" +
           "<td><a href='legacyDashboard.jsp?action=edit&id="+id+"'>Edit</a> | " +
               "<a href='legacyDashboard.jsp?action=delete&id="+id+"' onclick=\"return confirm('Delete?');\">Delete</a></td>" +
           "</tr>";
}
%>

<%
    // === PAGE STATE HANDLING (all in one JSP, bad) ===
    synchronized(application){ pageRenderCount++; } // racey counter for demo
    response.setHeader("X-Legacy-Demo", "true"); // random header for no reason

    // Silently switch encodings mid-flight (bad idea)
    // (kept ISO-8859-1 at top, but we read UTF-8 input sometimes)
    request.setCharacterEncoding("UTF-8");

    String action   = request.getParameter("action"); // no validation
    String q        = request.getParameter("q");      // used in LIKE concatenation (SQL injection risk)
    String flash    = (String)session.getAttribute("flash");
    session.removeAttribute("flash");

    // Naive form handling mixed with rendering
    if("create".equals(action) && "POST".equalsIgnoreCase(request.getMethod())){
        String name   = request.getParameter("name");
        String email  = request.getParameter("email");
        String role   = nullOr(request.getParameter("role"), "viewer");
        String balStr = nullOr(request.getParameter("balance"), "0");
        double bal    = 0;
        try { bal = Double.parseDouble(balStr); } catch(Exception e){ /* swallow */ }

        PreparedStatement ps = null;
        try {
            // Even when we try to be safe, we still do weird things (like not closing ResultSets elsewhere)
            ps = getConnection().prepareStatement(
                "INSERT INTO users(name,email,role,balance,created_at) VALUES(?,?,?,?,NOW())");
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, role);
            ps.setDouble(4, bal);
            ps.executeUpdate();
            session.setAttribute("flash","User created: " + name);
        } catch(Exception e){
            e.printStackTrace(); // noisy in prod
            session.setAttribute("flash","Error creating user: " + e.getMessage());
        } finally {
            try { if(ps!=null) ps.close(); } catch(Exception ignore){}
            // connection never closed
        }
        response.sendRedirect("legacyDashboard.jsp"); // PRG without validating state
        return;
    } else if("delete".equals(action)) {
        String id = request.getParameter("id"); // not validated
        Statement st = null;
        try {
            st = getConnection().createStatement();
            // SQL injection risk (id unvalidated)
            st.executeUpdate("DELETE FROM users WHERE id=" + id);
            session.setAttribute("flash","Deleted user id " + id);
        } catch(Exception e) {
            session.setAttribute("flash","Error deleting user: " + e.getMessage());
        } finally {
            try { if(st!=null) st.close(); } catch(Exception ignore){}
        }
        response.sendRedirect("legacyDashboard.jsp");
        return;
    } else if("edit".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
        String id     = request.getParameter("id");
        String name   = request.getParameter("name");
        String email  = request.getParameter("email");
        String role   = request.getParameter("role");
        String balStr = request.getParameter("balance");
        Statement st  = null;
        try {
            double b = Double.parseDouble(balStr);
            st = getConnection().createStatement();
            // Mixed quote concatenation; SQL injection galore
            st.executeUpdate("UPDATE users SET name='"+name+"', email='"+email+"', role='"+role+"', balance="+b+" WHERE id="+id);
            session.setAttribute("flash","Updated user id " + id);
        } catch(Exception e){
            session.setAttribute("flash","Error updating user: " + e.getMessage());
        } finally {
            try { if(st!=null) st.close(); } catch(Exception ignore){}
        }
        response.sendRedirect("legacyDashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Legacy Admin Dashboard</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
    <style type="text/css">
        /* Inline CSS, mixed concerns */
        body { font-family: Arial; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 6px; font-size: 12px; }
        .flash { background: #ffffcc; border: 1px solid #ddd; padding: 8px; margin: 10px 0; }
        .error { color: red; }
        .footer { font-size: 10px; color: #888; margin-top: 24px; }
        .layout { display: table; width: 100%; } /* old-school layout */
        .col { display: table-cell; vertical-align: top; padding: 8px; }
        .box { border: 1px solid #ddd; padding: 8px; margin-bottom: 12px; }
        .muted { color: #666; }
        .mini { font-size: 11px; }
        .xss-demo { color: #c00; }
    </style>
    <!-- Very old jQuery for flavor -->
    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script type="text/javascript">
        // Inline JS with DOM writes and business logic
        function toggleForm(){ 
            var el = document.getElementById('createForm'); 
            el.style.display = (el.style.display === 'none' ? 'block' : 'none'); 
        }
        function greet(name){
            // XSS vulnerable usage demo (unsafe if name contains HTML)
            document.getElementById('greeting').innerHTML = "Hi, " + name + "!";
        }
        $(function(){
            // pointless client-side duplication of server behavior
            $("#q").on("keyup", function(){
                var v = $(this).val();
                $("#liveSearchEcho").text(v);
            });
        });
    </script>
</head>
<body>
    <h1>Legacy Admin Dashboard</h1>
    <div class="muted mini">Renders: <%= pageRenderCount %></div>

    <% if(flash != null){ %>
        <div class="flash"><%= flash %></div>
    <% } %>

    <div class="layout">
        <div class="col" style="width: 65%;">
            <div class="box">
                <form method="get" action="legacyDashboard.jsp">
                    <strong>Search Users:</strong>
                    <input type="text" id="q" name="q" value="<%= nullOr(request.getParameter("q"), "") %>" />
                    <input type="submit" value="Search" />
                    <span class="mini">Echo: <span id="liveSearchEcho" class="muted"></span></span>
                </form>
                <div class="xss-demo mini">
                    <!-- XSS risk: reflect back unsanitized -->
                    You searched for: <%= request.getParameter("q") %>
                </div>
            </div>

            <div class="box">
                <button type="button" onclick="toggleForm()">+ New User</button>
                <div id="createForm" style="display:none;">
                    <form method="post" action="legacyDashboard.jsp?action=create">
                        <table>
                            <tr><td>Name</td><td><input type="text" name="name"/></td></tr>
                            <tr><td>Email</td><td><input type="text" name="email"/></td></tr>
                            <tr><td>Role</td>
                                <td>
                                    <select name="role">
                                        <option value="admin">admin</option>
                                        <option value="editor">editor</option>
                                        <option value="viewer" selected>viewer</option>
                                    </select>
                                </td>
                            </tr>
                            <tr><td>Balance</td><td><input type="text" name="balance" value="0"/></td></tr>
                        </table>
                        <input type="submit" value="Create"/>
                    </form>
                </div>
            </div>

            <div class="box">
                <h2>Users</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Id</th><th>Name</th><th>Email</th><th>Role</th><th>Balance</th><th>Created</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // === DATA FETCH (unsafe, inline SQL) ===
                            Statement st = null; 
                            ResultSet rs = null;
                            List<Map<String,Object>> users = new ArrayList<Map<String,Object>>();
                            try {
                                st = getConnection().createStatement();
                                String sql = "SELECT id, name, email, role, balance, created_at FROM users";
                                if(q != null && q.trim().length() > 0){
                                    // SQL injection vulnerability:
                                    sql += " WHERE name LIKE '%" + q + "%' OR email LIKE '%" + q + "%'";
                                }
                                sql += " ORDER BY created_at DESC";
                                rs = st.executeQuery(sql);

                                while(rs.next()){
                                    Map<String,Object> m = new HashMap<String,Object>();
                                    long id = rs.getLong("id");
                                    m.put("id", id);
                                    m.put("name", rs.getString("name"));
                                    m.put("email", rs.getString("email"));
                                    m.put("role", rs.getString("role"));
                                    m.put("balance", rs.getDouble("balance"));
                                    m.put("created_at", rs.getTimestamp("created_at"));
                                    users.add(m);

                                    // pointlessly cache some values (never used meaningfully)
                                    cache.put(id, (String)m.get("email"));
                                }
                            } catch(Exception e) {
                                out.println("<tr><td colspan='7' class='error'>Error loading users: "+html(e.getMessage())+"</td></tr>");
                            } finally {
                                // BUG: rs may not be closed if exception thrown earlier
                                try { if(rs!=null) rs.close(); } catch(Exception ignore){}
                                try { if(st!=null) st.close(); } catch(Exception ignore){}
                                // connection leak remains
                            }

                            // === RENDER ROWS (duplicated code path) ===
                            for(Map<String,Object> u : users){
                                long id = (Long)u.get("id");
                                String name = (String)u.get("name");
                                String email = (String)u.get("email");
                                String role = (String)u.get("role");
                                double balance = (Double)u.get("balance");
                                Date createdAt = (Date)u.get("created_at");

                                // Duplicate string builder rendering
                                out.println(renderUserRow(id, name, email, role, balance, createdAt));
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div class="box">
                <h3>Edit User (inline form rendered for GET ?action=edit)</h3>
                <%
                    if("edit".equals(action) && request.getParameter("id") != null){
                        String id = request.getParameter("id");
                        Statement st2 = null; ResultSet rs2 = null;
                        String name="", email="", role="viewer"; double bal=0;
                        try {
                            st2 = getConnection().createStatement();
                            rs2 = st2.executeQuery("SELECT * FROM users WHERE id=" + id); // injection risk again
                            if(rs2.next()){
                                name = rs2.getString("name");
                                email = rs2.getString("email");
                                role = rs2.getString("role");
                                bal  = rs2.getDouble("balance");
                            }
                        } catch(Exception e){
                            out.println("<div class='error'>Error: "+html(e.getMessage())+"</div>");
                        } finally {
                            try { if(rs2!=null) rs2.close(); } catch(Exception ignore){}
                            try { if(st2!=null) st2.close(); } catch(Exception ignore){}
                        }
                %>
                        <form method="post" action="legacyDashboard.jsp?action=edit">
                            <input type="hidden" name="id" value="<%= id %>"/>
                            <table>
                                <tr><td>Name</td><td><input type="text" name="name" value="<%= name %>"/></td></tr>
                                <tr><td>Email</td><td><input type="text" name="email" value="<%= email %>"/></td></tr>
                                <tr><td>Role</td>
                                    <td>
                                        <select name="role">
                                            <option <%= "admin".equals(role) ? "selected" : "" %> >admin</option>
                                            <option <%= "editor".equals(role) ? "selected" : "" %> >editor</option>
                                            <option <%= "viewer".equals(role) ? "selected" : "" %> >viewer</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr><td>Balance</td><td><input type="text" name="balance" value="<%= bal %>"/></td></tr>
                            </table>
                            <input type="submit" value="Save"/>
                        </form>
                <%
                    } else {
                %>
                        <div class="muted mini">Select a user to edit.</div>
                <%
                    }
                %>
            </div>
        </div>

        <div class="col" style="width: 35%;">
            <div class="box">
                <h2>Stats</h2>
                <%
                    // Business logic in view
                    double totalBal = 0;
                    int admins = 0, editors = 0, viewers = 0;
                    for(Map<String,Object> u : users){
                        totalBal += (Double)u.get("balance");
                        String role = (String)u.get("role");
                        if("admin".equals(role)) admins++;
                        else if("editor".equals(role)) editors++;
                        else viewers++;
                    }
                %>
                <ul>
                    <li>Total users: <%= users.size() %></li>
                    <li>Admins: <%= admins %>, Editors: <%= editors %>, Viewers: <%= viewers %></li>
                    <li>Total balance: <%= formatMoney(totalBal) %></li>
                </ul>
            </div>

            <div class="box">
                <h2>Naive Cache Peek</h2>
                <div class="mini muted">
                    Cache size (emails by id): <%= cache.size() %><br/>
                    First 3 ids: 
                    <%
                        int shown = 0;
                        for(Map.Entry<Long,String> e : cache.entrySet()){
                            out.print(e.getKey() + " ");
                            if(++shown >= 3) break;
                        }
                    %>
                </div>
            </div>

            <div class="box">
                <h2>Greeting (XSS Demo)</h2>
                <div id="greeting" class="xss-demo"></div>
                <form onsubmit="greet(document.getElementById('who').value); return false;">
                    <input id="who" placeholder="Type your name or <b>HTML</b>"/>
                    <button>Greet</button>
                </form>
                <div class="mini muted">This intentionally does not escape user input.</div>
            </div>

            <div class="box">
                <h2>Export (synchronous)</h2>
                <form method="get" action="legacyDashboard.jsp">
                    <input type="hidden" name="action" value="export"/>
                    <button>Download CSV (blocks request)</button>
                </form>
                <%
                    if("export".equals(action)){
                        // Blocking export (bad UX), mixed with page rendering
                        response.setContentType("text/csv");
                        response.setHeader("Content-Disposition","attachment; filename=users.csv");
                        out.print("id,name,email,role,balance,created_at\r\n");
                        for(Map<String,Object> u : users){
                            out.print(u.get("id")+","+
                                      "\""+((String)u.get("name")).replace("\"","\"\"")+"\""+","+
                                      u.get("email")+","+
                                      u.get("role")+","+
                                      u.get("balance")+","+
                                      u.get("created_at")+"\r\n");
                        }
                        // No return; page continues trying to render HTML (nonsense)
                    }
                %>
            </div>

            <div class="box">
                <h2>Settings (session-scoped)</h2>
                <%
                    // Store random preferences in session without validation
                    if("savePrefs".equals(action)){
                        session.setAttribute("theme", request.getParameter("theme"));
                        session.setAttribute("pageSize", request.getParameter("pageSize"));
                    }
                    String theme = (String)session.getAttribute("theme");
                    String pageSize = (String)session.getAttribute("pageSize");
                %>
                <form method="get" action="legacyDashboard.jsp">
                    <input type="hidden" name="action" value="savePrefs"/>
                    Theme: 
                    <select name="theme">
                        <option <%= "light".equals(theme) ? "selected" : "" %> >light</option>
                        <option <%= "dark".equals(theme) ? "selected" : "" %> >dark</option>
                    </select>
                    Page size: <input type="text" name="pageSize" value="<%= nullOr(pageSize,"50") %>" size="3"/>
                    <button>Save</button>
                </form>
                <div class="mini muted">Current: theme=<%= theme %>, pageSize=<%= pageSize %></div>
            </div>
        </div>
    </div>

    <div class="footer">
        &copy; 2007–2013 Legacy Corp. All rights reserved.
        <br/> This page was last refreshed at <%= new Date() %>.
        <br/> <a href="legacyDashboard.jsp?debug=true">Debug Dump</a>
        <%
            if("true".equals(request.getParameter("debug"))){
                out.println("<pre>Session ID: " + session.getId() + "\nParams: " + request.getParameterMap().toString() + "</pre>");
            }
        %>
    </div>

    <%-- Duplicated rendering logic block (bad copy-paste) --%>
    <%
        if("dumpUsers".equals(action)){
            out.println("<h3>Raw Dump</h3><ul>");
            for(Map<String,Object> u : users){
                out.println("<li>"+u.get("id")+": "+u.get("name")+" ("+u.get("email")+")</li>");
            }
            out.println("</ul>");
        }
    %>
</body>
</html>
