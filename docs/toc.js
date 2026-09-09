// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item affix "><a href="index.html">Welcome</a></li><li class="chapter-item affix "><li class="spacer"></li><li class="chapter-item affix "><li class="part-title">Course Information</li><li class="chapter-item "><a href="course/overview.html"><strong aria-hidden="true">1.</strong> Overview</a></li><li class="chapter-item "><a href="course/syllabus/index.html"><strong aria-hidden="true">2.</strong> Syllabus</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="course/syllabus/module1.html"><strong aria-hidden="true">2.1.</strong> Module 1: Set Theory</a></li><li class="chapter-item "><a href="course/syllabus/module2.html"><strong aria-hidden="true">2.2.</strong> Module 2: Binary Relations</a></li><li class="chapter-item "><a href="course/syllabus/module3.html"><strong aria-hidden="true">2.3.</strong> Module 3: Boolean Algebra</a></li><li class="chapter-item "><a href="course/syllabus/module4.html"><strong aria-hidden="true">2.4.</strong> Module 4: Formal Logic</a></li></ol></li><li class="chapter-item "><a href="course/schedule/index.html"><strong aria-hidden="true">3.</strong> Schedule</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="course/schedule/weekly.html"><strong aria-hidden="true">3.1.</strong> Weekly Plan</a></li><li class="chapter-item "><a href="course/schedule/deadlines.html"><strong aria-hidden="true">3.2.</strong> Deadlines</a></li></ol></li><li class="chapter-item "><a href="course/grading/index.html"><strong aria-hidden="true">4.</strong> Grading</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="course/grading/components.html"><strong aria-hidden="true">4.1.</strong> Components</a></li><li class="chapter-item "><a href="course/grading/scale.html"><strong aria-hidden="true">4.2.</strong> Scale &amp; Requirements</a></li><li class="chapter-item "><a href="course/grading/policies.html"><strong aria-hidden="true">4.3.</strong> Policies</a></li></ol></li><li class="chapter-item "><li class="spacer"></li><li class="chapter-item affix "><li class="part-title">Assessments</li><li class="chapter-item "><a href="assessments/homework/index.html"><strong aria-hidden="true">5.</strong> Homework</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="assessments/homework/submission.html"><strong aria-hidden="true">5.1.</strong> Submission Guidelines</a></li><li class="chapter-item "><a href="assessments/homework/defense.html"><strong aria-hidden="true">5.2.</strong> Defense Process</a></li><li class="chapter-item "><a href="assessments/homework/tips.html"><strong aria-hidden="true">5.3.</strong> Tips &amp; FAQs</a></li></ol></li><li class="chapter-item "><a href="assessments/tests/index.html"><strong aria-hidden="true">6.</strong> Tests</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="assessments/tests/format.html"><strong aria-hidden="true">6.1.</strong> Format &amp; Topics</a></li><li class="chapter-item "><a href="assessments/tests/test1.html"><strong aria-hidden="true">6.2.</strong> Test 1: Set Theory</a></li><li class="chapter-item "><a href="assessments/tests/test2.html"><strong aria-hidden="true">6.3.</strong> Test 2: Relations</a></li><li class="chapter-item "><a href="assessments/tests/test3.html"><strong aria-hidden="true">6.4.</strong> Test 3: Boolean Algebra</a></li><li class="chapter-item "><a href="assessments/tests/test4.html"><strong aria-hidden="true">6.5.</strong> Test 4: Logic</a></li><li class="chapter-item "><a href="assessments/tests/tips.html"><strong aria-hidden="true">6.6.</strong> Tips &amp; FAQs</a></li></ol></li><li class="chapter-item "><a href="assessments/colloquiums/index.html"><strong aria-hidden="true">7.</strong> Colloquiums</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="assessments/colloquiums/tm1.html"><strong aria-hidden="true">7.1.</strong> TM1: Set Theory &amp; Relations</a></li><li class="chapter-item "><a href="assessments/colloquiums/tm2.html"><strong aria-hidden="true">7.2.</strong> TM2: Boolean Algebra &amp; Logic</a></li><li class="chapter-item "><a href="assessments/colloquiums/preparation.html"><strong aria-hidden="true">7.3.</strong> Preparation Guide</a></li></ol></li><li class="chapter-item "><a href="assessments/exam/index.html"><strong aria-hidden="true">8.</strong> Final Exam</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="assessments/exam/structure.html"><strong aria-hidden="true">8.1.</strong> Structure</a></li></ol></li><li class="chapter-item "><li class="spacer"></li><li class="chapter-item affix "><li class="part-title">Resources</li><li class="chapter-item "><a href="resources/materials.html"><strong aria-hidden="true">9.</strong> Course Materials</a></li><li class="chapter-item "><a href="resources/support.html"><strong aria-hidden="true">10.</strong> Help &amp; Support</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0].split("?")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
