<%@ page import="java.util.*"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.lang.reflect.*"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="java.security.*"%>

<%!
    public String replace(String s, String source, String target) {
        String ret = s;
        int idx = ret.indexOf(source);
        while(idx > -1) {
            ret = ret.substring(0, idx) + target + ret.substring(idx+source.length());
            idx = ret.indexOf(source, idx+target.length());
        }
        return ret;
    }

    public String linkClass(String inputStr) {
        String result = inputStr;
        String patternStr = "([a-zA-Z0-9]{1,}\\.){1,}[a-zA-Z0-9]{1,}[@|$][a-zA-Z0-9]{1,}]{0,1}";
        Pattern pattern = Pattern.compile(patternStr);
        Matcher matcher = pattern.matcher(inputStr);
        String cname = null;
        int cnt = 0;
        while(matcher.find()) {
            cname = matcher.group();
            if(cname.lastIndexOf('@') > 0) {
                cname = cname.substring(0, cname.lastIndexOf('@'));
            }
            String rep = "<a href='?classname="+cname+"'>"+cname+"</a>";
            result = replace(result, cname, rep);
            cnt++;
        }

        if(cnt == 0) {
            patternStr = "([a-zA-Z0-9]{1,}\\.){1,}[a-zA-Z0-9]{1,}";
            pattern = Pattern.compile(patternStr);
            matcher = pattern.matcher(result);
            while(matcher.find()) {
                cname = matcher.group();
                String rep = "<a href='?classname="+cname+"'>"+cname+"</a>";
                result = replace(result, cname, rep);
            }
        }

        return result;
    }

    public String linkClassInfo(String inputStr) {
        String result = FQNtoType(inputStr);
        result = linkClass(result);
        return (result==null||result.equals(""))?"&nbsp;":result;
    }

    public String checkLocation(String inputStr) {
        int idx = inputStr.lastIndexOf(':');
        if(idx > -1) {
            inputStr = inputStr.substring(idx-1);
        }
        return inputStr;
    }

    public String FQNtoType(String fqn) {
        String retType = null;
        String temp = fqn;
        boolean isArr = false;
        int arrCnt = 0;
        while(temp.startsWith("[")) {
            isArr = true;
            temp = temp.substring(1);
            arrCnt++;
        }
        if(isArr) {
            char t = temp.charAt(0);
            switch(t) {
                case 'B' :
                    retType = "byte"; break;
                case 'C' :
                    retType = "char"; break;
                case 'D' :
                    retType = "double"; break;
                case 'F' :
                    retType = "float"; break;
                case 'I' :
                    retType = "int"; break;
                case 'J' :
                    retType = "long"; break;
                case 'S' :
                    retType = "short"; break;
                case 'Z' :
                    retType = "boolean"; break;
                case 'L' :
                    retType = temp.substring(1, temp.indexOf(';',1)); break;
            }
        }
        if(retType == null) {
            return fqn;
        } else {
            if(isArr) {
                for(int i=0; i<arrCnt; i++) {
                    retType += "[]";
                }
            }
            return retType;
        }
    }

    public String getNotFoundMessage(String className) {
        return "<br><i><b>can't find</b> the class '<font color=red>" + className + "</font>' in the classloader.<br>";
    }


    String pname[] = {
        "JBOSS:",
        "Log4J:",
        "OracleJDBCDriver:",
        "JavaMail:",
        "LDAP:",
        "JDom:",
        "Jaxp:",
        "WebT:",
    };

    String cname[] = {
        "/javax/servlet/http/HttpServlet.class",
        "/org/apache/log4j/BasicConfigurator.class",
        "/oracle/jdbc/driver/OracleDriver.class",
        "/com/sun/mail/pop3/Response.class",
        "/com/novell/ldap/LDAPConnection.class",
        "/org/jdom/input/DOMBuilder.class",
        "/javax/xml/parsers/SAXParser.class",
        "/tmax/webt/WebtSystem.class"
    };
%>



<html>
<head>
    <style type="text/css">
        body{font-size:10pt;font-family:Arial, Apple Gothic, Dotum, Gulim}
        h2{font-size:15pt}
        h3{font-size:13pt}
        th{font-size:11pt}
        td{font-size:10pt}
        .pt{ font-size:10pt;}
    </style>
    <script language="javascript">
        function show_hide() {
            if(property.style.display == "") {
                property.style.display = "none";
            } else {
                property.style.display = "";
            }
        }
    </script>
</head>


<%
    java.net.URL url = null;
    String name = null;
    String value = null;

    String className = request.getParameter("classname");
    if(className == null || className.length() == 0) {
%>
        <body onLoad='javascript:document.theform.classname.focus()'>
        <h2><center>[JVM Property & Class Information View]</center></h2>
        <hr align=center><br>
        <h3>[Class Information]</h3>
        <b><font color=red>INPUT : PackageName/ClassName (without extension)</font></b><br>
        <b><font color=red>EXAMPLE : javax/servlet/http/HttpServlet</font></b>
        <form name='theform' method='POST' action=''>
        <b>Enter name of class : </b><input type='text' name='classname' size=50>
        <input type='submit' value="Search">
        </form>
        <hr align=center>
        <input type='button' value="System Property" onClick="show_hide()">
        <div id="property" style="display:none">
            <h3>[Loaded Package&Class List]</h3>
<%
            for (int i = 0; i < cname.length; i++) {
                url = this.getClass().getResource(cname[i]);
                if (url == null) {
                    out.println("<b>" + pname[i] + "</b>(" + cname[i] + ") => Not Found");
                } else {
                    out.println("<b>" + pname[i] + "</b>(" + cname[i] + ")");
                    out.println(" => [" + url.getFile() + "]\n");
                }
                out.println("<br>");
            }

%>
            <br><hr align=center>
            <h3>[Security Provider List]</h3>
<%
            Provider[] providers = Security.getProviders();
            for (int i = 0; i < providers.length; i++) {
                out.println("<b>");
                out.println(providers[i].getName());
                out.println("</b> : ");
                out.println(providers[i].getInfo());
                out.println("<br>");
            }
%>
            <br><hr align=center>
            <h3>[System Property List]</h3>
<%
            Properties prop = System.getProperties();
            Enumeration enum1 = prop.propertyNames();
            while (enum1.hasMoreElements()) {
                name = (String) enum1.nextElement();
                value = (String) prop.get(name);
                out.println("<b>" + name + "</b>: " + value);
                out.println("<br>");
            }
%>
        </div>
        </body>
        </html>
<%
        return;
    }
%>


<body>
    <h3><a name="classsearch">[Class Method/Field Information]</h3>

<%
    String save_classname = className;

    if(!className.startsWith("/"))
        className = "/" + className;
    className = className.replace('.', '/');
    java.net.URL classUrl = getClass().getResource(className + ".class");


    if(classUrl == null) {
        out.println(getNotFoundMessage(className));
    } else {
        className = save_classname;
        if(className.startsWith("/"))
            className = className.substring(1);
        className = className.replace('/', '.');
        Class cls;
        try {
            cls = Class.forName(className);
	        ClassLoader cl = cls.getClassLoader();
%>
            <menu>
                <li>Summary</li><br><br>

                <table border=1 cellspacing=0 width="90%">
                <thead>
                    <tr bgcolor="#CCCCFF">
                        <th width=150>Category</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td align=center>Name</td>
                        <td align=center><%=className%></td>
                    </tr>
                    <tr>
                        <td align=center>Location</td>
                        <td align=center><%=checkLocation(classUrl.getFile())%></td>
                    </tr>
                    <tr>
                        <td align=center>ClassLoader</td>
                        <td align=center><%=(cl==null)?"&nbsp;":linkClassInfo(cl.toString())%></td>
                    </tr>
                    <tr>
                        <td align=center>SuperClass</td>
                        <td align=center><%=linkClassInfo((cls.getSuperclass()==null)?"&nbsp;":cls.getSuperclass().getName())%></td>
                    </tr>
                    <tr>
                        <td align=center>Interface</td>
                        <td align=center><%=cls.isInterface()?"Yes":"No"%></td>
                    </tr>
                    <tr>
                        <td align=center>Primitive</td>
                        <td align=center><%=cls.isPrimitive()?"Yes":"No"%></td>
                    </tr>
                </tbody>
                </table>


                <br><br>

<%
            if(cl != null) {

                Class[] ifs = cls.getInterfaces();
                Constructor[] dcons = cls.getDeclaredConstructors();
                Field[] dfls = cls.getDeclaredFields();
                Method[] dmtds = cls.getDeclaredMethods();
                Class[] dcls = cls.getDeclaredClasses();
%>

                <li>Detail</li><br><br>

                <table border=1 cellspacing=0 width="90%">
                <thead>
                    <tr bgcolor="#CCCCFF">
                        <th width=150>Category</th>
                        <th width=250>Type</th>
                        <th>Detail</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td align=center rowspan=<%=ifs.length%>>Implemented</td>
                        <td align=center rowspan=<%=ifs.length%>>N/A</td>
                        <%
                            for(int i=0; i<ifs.length; i++) {
                                if(i > 0)
                                    out.println("</tr><tr>");
                                out.println("<td align=center>" + linkClassInfo(ifs[i].getName()) + "</td>");
                            }
                            if(ifs.length == 0)
                                out.println("<td align=center>&nbsp;</td>");
                        %>
                    </tr>
                    <tr>
                        <td align=center rowspan=<%=dcons.length%>>Constructor</td>
                        <td align=center rowspan=<%=dcons.length%>>N/A</td>
                        <%
                            for(int i=0; i<dcons.length; i++) {
                                String conStr = dcons[i].getName();
                                if(i > 0)
                                    out.println("</tr><tr>");
                                out.println("<td align=center>" + conStr.substring(conStr.lastIndexOf('.')+1) + "(");
                                Class[] params = dcons[i].getParameterTypes();
                                for(int j=0; j<params.length; j++) {
                                    if(j!=0) out.println(", ");
                                    out.println(linkClassInfo(params[j].getName()));
                                }
                                out.println(")</td>");
                            }
                            if(dcons.length == 0)
                                out.println("<td align=center>&nbsp;</td>");
                        %>
                    </tr>
                    <tr>
                        <td align=center rowspan=<%=dfls.length%>>Field</td>
                        <%
                            for(int i=0; i<dfls.length; i++) {
                                Class type = dfls[i].getType();
                                if(i > 0)
                                    out.println("</tr><tr>");
                                out.println("<td align=center>" + linkClassInfo(type.getName()) + "</td>");
                                out.println("<td align=center>" + dfls[i].getName() + "</td>");
                            }
                            if(dfls.length == 0) {
                                out.println("<td align=center>&nbsp;</td>");
                                out.println("<td align=center>&nbsp;</td>");
                            }
                        %>
                    </tr>
                    <tr>
                        <td align=center rowspan=<%=dmtds.length%>>Method</td>
                        <%
                            for(int i=0; i<dmtds.length; i++) {
                                Class type = dmtds[i].getReturnType();
                                if(i > 0)
                                    out.println("</tr><tr>");
                                out.println("<td align=center>" + linkClassInfo(type.getName()) + "</td>");
                                out.println("<td align=center>" + dmtds[i].getName() + "(");
                                Class[] params = dmtds[i].getParameterTypes();
                                for(int j=0; j<params.length; j++) {
                                    if(j!=0) out.println(", ");
                                    out.println(linkClassInfo(params[j].getName()));
                                }
                                out.println(")</tr>");
                            }
                            if(dmtds.length == 0) {
                                out.println("<td align=center>&nbsp;</td>");
                                out.println("<td align=center>&nbsp;</td>");
                            }
                        %>
                    </tr>
                    <tr>
                        <td align=center rowspan=<%=dcls.length%>>InnerClass</td>
                        <td align=center rowspan=<%=dcls.length%>>N/A</td>
                        <%
                            for(int i=0; i<dcls.length; i++) {
                                if(i > 0)
                                    out.println("</tr><tr>");
                                out.println("<td align=center>" + linkClassInfo(dcls[i].getName()) + "</td>");
                            }
                            if(dcls.length == 0)
                                out.println("<td align=center>&nbsp;</td>");
                        %>
                    </tr>
                </tbody>
                </table>
            </menu>
<%
            }
        } catch(NoClassDefFoundError e1) {
            out.println(getNotFoundMessage(className));
            e1.printStackTrace();
        } catch(ClassNotFoundException e2) {
            out.println(getNotFoundMessage(className));
            e2.printStackTrace();
        }
    }
%>
        <br>
        <center>
            <table border="0" cellspacing="0" cellpadding="0" align="center">
            <tr>
                <td align="center"><input type="button" value="back" onClick="javascript:history.back();"></td>
            </tr>
            </table>
        </center>

    </body>
</html>
