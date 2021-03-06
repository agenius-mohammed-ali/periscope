context("periscope - UI functionality")

test_that("fw_create_header", {
    result <- periscope:::fw_create_header()
    expect_equal(result$name, "header")
    expect_equal(result$attribs, list(class = "main-header"))

    result.children <- result$children
    expect_equal(length(result.children), 3)
    expect_equal(result.children[[1]], NULL) ## ?

    expect_equal(result.children[[2]]$name, "span")
    expect_equal(result.children[[2]]$attribs$class, "logo")
    expect_equal(length(result.children[[2]]$children), 1)

    expect_equal(result.children[[2]]$children[[1]]$name, "div")
    expect_equal(result.children[[2]]$children[[1]]$attribs, list(class = "periscope-busy-ind"))

    expect_equal(length(result.children[[2]]$children[[1]]$children), 2)
    expect_equal(result.children[[2]]$children[[1]]$children[[1]], "Working")
})

check_sidebar_result <- function(result, showsidebar = TRUE,  basic_existing = FALSE, advanced_existing = FALSE) {
    expect_equal(result$name, "aside")
    if (length(result$attribs) == 2) {
        expect_equal(result$attribs, list(class = "main-sidebar", 'data-collapsed' = "false"))
    } else {
        if (showsidebar) {
            expect_equal(result$attribs, list(id = "sidebarCollapsed", class = "main-sidebar", 'data-collapsed' = "false"))   
        } else {
            expect_equal(result$attribs, list(id = "sidebarCollapsed", class = "main-sidebar", 'data-collapsed' = "true"))   
        }
    }

    result.children <- result$children
    expect_equal(length(result.children), 2)
    if (showsidebar) {
        expect_equal(result.children[[1]], NULL) ## ?
    } else {
        expect_equal(length(result.children[[1]]), 3)
        expect_equal(result.children[[1]][[1]], "head")
        expect_equal(class(result.children[[1]][[2]]), "list")
        expect_equal(class(result.children[[1]][[3]]), "list")
    }

    expect_equal(result.children[[2]]$name, "section")
    expect_equal(result.children[[2]]$attribs$class, "sidebar")
    expect_equal(result.children[[2]][[2]]$id, "sidebarItemExpanded")

    result.subchilds <- result.children[[2]]$children[[1]]
    expect_equal(length(result.subchilds), 3)

    expect_equal(result.subchilds[[1]][[1]]$name, "script")
    expect_true(grepl("Set using set_app_parameters\\() in program/global.R", result.subchilds[[1]][[1]]$children[[1]]))
    
    if (basic_existing || advanced_existing) {
        expect_equal(result.subchilds[[3]]$name, "div")
        
        if (basic_existing && advanced_existing) {
            expect_equal(result.subchilds[[3]]$attribs$class, "tab-content")
        } else {
            expect_equal(result.subchilds[[3]]$attribs$class, "notab-content")
        }
    }
}

test_that("fw_create_sidebar no sidebar", {
    result <- periscope:::fw_create_sidebar(showsidebar = F, resetbutton = F)
    
    check_sidebar_result(result, showsidebar = FALSE)
})

test_that("fw_create_sidebar empty", {
    result <- periscope:::fw_create_sidebar(showsidebar = T, resetbutton = F)

    check_sidebar_result(result, showsidebar = TRUE)
})

test_that("fw_create_sidebar only basic", {
    # setup
    side_basic            <- shiny::isolate(.g_opts$side_basic)
    .g_opts$side_basic    <- list(tags$p())
    side_advanced         <- shiny::isolate(.g_opts$side_advanced)
    .g_opts$side_advanced <- NULL

    result <- periscope:::fw_create_sidebar(showsidebar = T, resetbutton = F)

    check_sidebar_result(result, showsidebar = TRUE, basic_existing = TRUE, advanced_existing = FALSE)

    # teardown
    .g_opts$side_basic    <- side_basic
    .g_opts$side_advanced <- side_advanced
})

test_that("fw_create_sidebar only advanced", {
    # setup
    side_basic            <- shiny::isolate(.g_opts$side_basic)
    .g_opts$side_basic    <- NULL
    side_advanced         <- shiny::isolate(.g_opts$side_advanced)
    .g_opts$side_advanced <- list(tags$p())

    result <- periscope:::fw_create_sidebar()

    check_sidebar_result(result, showsidebar = TRUE, basic_existing = FALSE, advanced_existing = TRUE)

    # teardown
    .g_opts$side_basic    <- side_basic
    .g_opts$side_advanced <- side_advanced
})

test_that("fw_create_sidebar basic and advanced", {
    # setup
    side_basic            <- shiny::isolate(.g_opts$side_basic)
    .g_opts$side_basic    <- list(tags$p())
    side_advanced         <- shiny::isolate(.g_opts$side_advanced)
    .g_opts$side_advanced <- list(tags$p())

    result <- periscope:::fw_create_sidebar()

    check_sidebar_result(result, showsidebar = TRUE, basic_existing = TRUE, advanced_existing = TRUE)

    # teardown
    .g_opts$side_basic    <- side_basic
    .g_opts$side_advanced <- side_advanced
})

check_body_result <- function(result, logging = TRUE) {
    expect_equal(result$name, "div")
    expect_equal(result$attribs, list(class = "content-wrapper"))

    result.children <- result$children
    expect_equal(length(result.children), 1)

    expect_equal(result.children[[1]]$name, "section")
    expect_equal(result.children[[1]]$attribs$class, "content")

    result.subchilds <- result.children[[1]]$children
    expect_equal(length(result.subchilds), 4)

    expect_equal(result.subchilds[[1]]$name, "head")
    # check if tab title is set in javascript
    expect_true(grepl("document.title = 'Set using set_app_parameters\\() in program/global.R'", result.subchilds[[1]]$children[[2]]$children))

    if (logging) {
        expect_equal(class(result.subchilds[[2]]), "shiny.tag")
        expect_equal(result.subchilds[[2]]$name, "div")
        expect_equal(result.subchilds[[2]]$attribs$class, "modal sbs-modal fade")
        expect_equal(result.subchilds[[2]]$attribs$id, "titleinfobox")
        expect_equal(result.subchilds[[2]]$attribs$tabindex, "-1")
        expect_equal(result.subchilds[[2]]$attribs$`data-sbs-trigger`, "titleinfobox_trigger")

        expect_equal(length(result.subchilds[[4]]), 3)

        expect_equal(result.subchilds[[4]]$name, "div")
        expect_equal(result.subchilds[[4]]$attribs, list(class = "col-sm-12"))
        result.subsubchilds <- result.subchilds[[4]]$children

        expect_equal(result.subsubchilds[[1]]$name, "div")
        expect_equal(result.subsubchilds[[1]]$attribs, list(class = "box collapsed-box"))

        result.subsubsubchilds <- result.subsubchilds[[1]]$children
        expect_equal(length(result.subsubsubchilds), 3)
        expect_equal(result.subsubsubchilds[[1]]$name, "div")
        expect_equal(result.subsubsubchilds[[1]]$attribs, list(class = "box-header"))

        result.subsubsubsubchilds <- result.subsubsubchilds[[1]]$children
        expect_equal(length(result.subsubsubsubchilds), 2)
        expect_equal(result.subsubsubsubchilds[[1]]$name, "h3")
        expect_equal(result.subsubsubsubchilds[[1]]$attribs, list(class = "box-title"))

        result.subsubsubsubsubchilds <- result.subsubsubsubchilds[[1]]$children
        expect_equal(result.subsubsubsubsubchilds[[1]], "User Action Log")

        result.subsubsubsubsubchilds <- result.subsubsubsubchilds[[2]]$children
        expect_equal(result.subsubsubsubsubchilds[[1]]$name, "button")
        expect_equal(result.subsubsubsubsubchilds[[1]]$attribs, list(class = "btn btn-box-tool", 'data-widget' = "collapse"))
        expect_equal(length(result.subsubsubsubsubchilds[[1]]$children), 1)

        expect_equal(result.subsubsubsubsubchilds[[1]]$children[[1]]$name, "i")
        expect_equal(result.subsubsubsubsubchilds[[1]]$children[[1]]$attribs, list(class = "fa fa-plus"))
        expect_equal(result.subsubsubsubsubchilds[[1]]$children[[1]]$children, list())
    } else {
        expect_equal(result.subchilds[[2]], NULL)
        expect_equal(result.subchilds[[3]], NULL)
        expect_equal(result.subchilds[[4]], NULL)
    }
}

test_that("fw_create_body app_info", {

    # setup
    app_info         <- shiny::isolate(.g_opts$app_info)
    .g_opts$app_info <- HTML("<b>app_info</b>")

    result <- periscope:::fw_create_body()
    check_body_result(result)

    # teardown
    .g_opts$app_info <- app_info
})

test_that("fw_create_body no log", {

    # setup
    show_userlog         <- shiny::isolate(.g_opts$show_userlog)
    .g_opts$show_userlog <- FALSE

    result <- periscope:::fw_create_body()
    check_body_result(result, logging = FALSE)

    # teardown
    .g_opts$show_userlog <- show_userlog
})

test_that("add_ui_sidebar_basic", {
    result <- add_ui_sidebar_basic(elementlist = NULL, append = FALSE, tabname = "Basic")
    expect_null(result, "add_ui_sidebar_basic")
})

test_that("add_ui_sidebar_basic append", {
    result <- add_ui_sidebar_basic(elementlist = NULL, append = TRUE, tabname = "Basic")
    expect_null(result, "add_ui_sidebar_basic")
})

test_that("add_ui_sidebar_advanced", {
    result <- add_ui_sidebar_advanced(elementlist = NULL, append = FALSE, tabname = "Advanced")
    expect_null(result, "add_ui_sidebar_advanced")
})

test_that("add_ui_sidebar_advanced append", {
    result <- add_ui_sidebar_advanced(elementlist = NULL, append = TRUE, tabname = "Advanced")
    expect_null(result, "add_ui_sidebar_advanced")
})

test_that("add_ui_body", {
    result <- add_ui_body(elementlist = NULL, append = FALSE)
    expect_null(result, "add_ui_body")
})

test_that("add_ui_body", {
    result <- add_ui_body(elementlist = NULL, append = TRUE)
    expect_null(result, "add_ui_body")
})

test_that("ui_tooltip", {
    result <- ui_tooltip(id = "id", label = "mylabel", text = "mytext")
    expect_equal(result$name, "span")
    expect_equal(result$attribs, list(class = "periscope-input-label-with-tt"))
    result.children <- result$children
    expect_equal(length(result.children), 3)
    expect_equal(result.children[[1]], "mylabel")
})

test_that("ui_tooltip no text", {
    expect_warning(ui_tooltip(id = "id", label = "mylabel", text = ""), "ui_tooltip\\() called without tooltip text.")
})

test_that("fw_create_header_plus", {
    result <- periscope:::fw_create_header_plus()
    expect_equal(result$name, "header")
    expect_equal(result$attribs, list(class = "main-header"))

    result.children <- result$children
    expect_equal(length(result.children), 3)
    expect_equal(result.children[[1]], NULL) ## ?

    expect_equal(result.children[[2]]$name, "span")
    expect_equal(result.children[[2]]$attribs$class, "logo")
    expect_equal(length(result.children[[2]]$children), 1)

    expect_equal(result.children[[2]]$children[[1]]$name, "div")
    expect_equal(result.children[[2]]$children[[1]]$attribs, list(class = "periscope-busy-ind"))

    expect_equal(length(result.children[[2]]$children[[1]]$children), 2)
    expect_equal(result.children[[2]]$children[[1]]$children[[1]], "Working")

    expect_equal(result.children[[3]]$name, "nav")
    expect_equal(result.children[[3]]$attribs$class, "navbar navbar-static-top")
    expect_equal(length(result.children[[3]]$children), 4)

    expect_equal(result.children[[3]]$children[[1]]$name, "span")
    expect_equal(result.children[[3]]$children[[1]]$attribs, list(style = "display:none;"))

    expect_equal(result.children[[3]]$children[[2]]$name, "a")
    expect_equal(result.children[[3]]$children[[2]]$attribs, list(href = "#", class = "sidebar-toggle", `data-toggle` = "offcanvas", role = "button"))

    expect_equal(result.children[[3]]$children[[3]]$name, "div")
    expect_equal(result.children[[3]]$children[[3]]$attribs, list(class = "navbar-custom-menu", style = "float: left; margin-left: 10px;"))

    expect_equal(result.children[[3]]$children[[4]]$name, "div")
    expect_equal(result.children[[3]]$children[[4]]$attribs, list(class = "navbar-custom-menu"))
})

test_that("fw_create_right_sidebar", {
    result <- periscope:::fw_create_right_sidebar()

    expect_equal(length(result), 2)
    expect_equal(result[[1]]$name, "head")
    expect_equal(length(result[[1]]$attribs), 0)
    expect_equal(length(result[[1]]$children), 1)

    result1.children <- result[[1]]$children[[1]]

    expect_equal(result1.children$name, "style")
    expect_equal(length(result1.children$attribs), 0)

    expect_equal(result[[2]]$name, "div")
    expect_equal(result[[2]]$attribs, list(id = "controlbar"))
    expect_equal(length(result[[2]]$children), 2)

    result2.children <- result[[2]]$children

    expect_equal(result2.children[[1]]$name, "aside")
    expect_equal(length(result2.children[[1]]$children), 2)

    expect_equal(result2.children[[1]]$children[[1]]$name, "ul")
    expect_equal(result2.children[[1]]$children[[1]]$attribs, list(class = "nav nav-tabs nav-justified control-sidebar-tabs"))

    expect_equal(result2.children[[1]]$children[[2]]$name, "div")
    expect_equal(result2.children[[1]]$children[[2]]$attribs, list(class = "controlbar tab-content"))

    expect_equal(result2.children[[2]]$name, "div")
    expect_equal(result2.children[[2]]$attribs, list(class = "control-sidebar-bg", style = "width: 230px;"))
})

test_that("add_ui_sidebar_right", {
    result <- add_ui_sidebar_right(elementlist = NULL)
    expect_null(result, "add_ui_sidebar_right")
})

test_that("add_ui_sidebar_right with append", {
    result <- add_ui_sidebar_right(elementlist = NULL, append = TRUE)
    expect_null(result, "add_ui_sidebar_right")
})
