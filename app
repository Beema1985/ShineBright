import json
import os
import re
import urllib.parse
from datetime import datetime
from pathlib import Path
import streamlit as st

# ---------------------------------------------------------------------------
# Page & Theme Configuration
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="ShineBright | Learn • Explore • Create • Shine",
    page_icon=":material/auto_awesome:",
    layout="wide",
    initial_sidebar_state="expanded",
)

DATA_FILE = Path(__file__).parent / "shinebright_data.json"


# ---------------------------------------------------------------------------
# Default Dynamic Data (CBSE & IB CRS AI + News + Messages)
# ---------------------------------------------------------------------------
def get_default_data() -> dict:
    return {
        "cbse": {
            "Computer Science (CS)": {
                "Grade 11": [
                    {
                        "id": "cs11-1",
                        "title": "Python Fundamentals & Control Flow",
                        "type": "PDF Notes",
                        "summary": "Variables, data types, operators, conditional branching, and iterative loops with classroom exercises.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "cs11-2",
                        "title": "Strings, Lists, Tuples & Dictionaries",
                        "type": "Code Lab",
                        "summary": "Hands-on sequence manipulation, list comprehensions, and dictionary traversal examples.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "cs11-3",
                        "title": "Society, Law & Cyber Ethics",
                        "type": "Presentation",
                        "summary": "Digital footprint, intellectual property rights, cyber safety, and responsible computing.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                ],
                "Grade 12": [
                    {
                        "id": "cs12-1",
                        "title": "Functions, File Handling & Exception Basics",
                        "type": "PDF Notes",
                        "summary": "Modular programming, text/CSV/binary file operations, and structured problem solving.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "cs12-2",
                        "title": "Data Structures: Stacks in Python",
                        "type": "Video Lecture",
                        "summary": "LIFO principles, push/pop operations, and postfix/expression evaluation walkthroughs.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "cs12-3",
                        "title": "Computer Networks & SQL Connectivity",
                        "type": "Code Lab",
                        "summary": "Networking protocols, topologies, DDL/DML queries, and Python-MySQL integration.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                ],
            },
            "Informatics Practices (IP)": {
                "Grade 11": [
                    {
                        "id": "ip11-1",
                        "title": "Introduction to Python & Pandas Series",
                        "type": "Code Lab",
                        "summary": "Creating Series objects, indexing, slicing, and vectorized operations for data analysis.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "ip11-2",
                        "title": "Database Concepts & SQL Queries",
                        "type": "PDF Notes",
                        "summary": "Relational tables, primary/foreign keys, SELECT, WHERE, ORDER BY, and aggregate functions.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "ip11-3",
                        "title": "Emerging Trends in IT",
                        "type": "Presentation",
                        "summary": "AI, IoT, cloud computing, big data, and blockchain explained for students.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                ],
                "Grade 12": [
                    {
                        "id": "ip12-1",
                        "title": "Data Handling Using Pandas DataFrames",
                        "type": "Code Lab",
                        "summary": "Filtering, grouping, sorting, missing values, and importing/exporting CSV files.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "ip12-2",
                        "title": "Data Visualisation with Matplotlib",
                        "type": "PDF Notes",
                        "summary": "Line charts, bar graphs, histograms, labels, legends, and saving visual reports.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                    {
                        "id": "ip12-3",
                        "title": "Societal Impacts & Digital Wellbeing",
                        "type": "Presentation",
                        "summary": "E-waste management, data privacy, health awareness, and ethical technology practices.",
                        "url": "https://cbseacademic.nic.in/",
                    },
                ],
            },
        },
        "ib_crs_ai": {
            "Year 1": {
                "Unit 1: Foundations of Artificial Intelligence": [
                    {
                        "id": "ib1-u1-1",
                        "title": "Problem Framing & Search Paradigms",
                        "type": "PDF Notes",
                        "summary": "State spaces, uninformed vs. informed search, and real-world AI problem formulation.",
                        "url": "https://www.ibo.org/",
                    },
                    {
                        "id": "ib1-u1-2",
                        "title": "Data Literacy & Exploratory Analysis",
                        "type": "Code Lab",
                        "summary": "Dataset quality, feature distributions, bias awareness, and preprocessing workflows.",
                        "url": "https://www.ibo.org/",
                    },
                ],
                "Unit 2: Supervised Learning & Model Evaluation": [
                    {
                        "id": "ib1-u2-1",
                        "title": "Regression & Classification Essentials",
                        "type": "Presentation",
                        "summary": "Linear/logistic models, decision trees, train/test splits, and overfitting prevention.",
                        "url": "https://www.ibo.org/",
                    },
                    {
                        "id": "ib1-u2-2",
                        "title": "Confusion Matrix & Metrics Workshop",
                        "type": "Code Lab",
                        "summary": "Accuracy, precision, recall, F1-score, and choosing metrics based on impact.",
                        "url": "https://www.ibo.org/",
                    },
                ],
            },
            "Year 2": {
                "Unit 1: Neural Networks & Deep Learning": [
                    {
                        "id": "ib2-u1-1",
                        "title": "Perceptrons, Backpropagation & Activation Functions",
                        "type": "PDF Notes",
                        "summary": "How multi-layer networks learn representations and gradient descent fundamentals.",
                        "url": "https://www.ibo.org/",
                    },
                    {
                        "id": "ib2-u1-2",
                        "title": "Vision & Sequence Architectures Overview",
                        "type": "Video Lecture",
                        "summary": "Convolutional patterns, embeddings, and attention concepts in modern AI systems.",
                        "url": "https://www.ibo.org/",
                    },
                ],
                "Unit 2: AI Ethics, Governance & Capstone Research": [
                    {
                        "id": "ib2-u2-1",
                        "title": "Algorithmic Fairness, Transparency & Accountability",
                        "type": "PDF Notes",
                        "summary": "Case studies on model bias, explainability, privacy, and societal responsibility.",
                        "url": "https://www.ibo.org/",
                    },
                    {
                        "id": "ib2-u2-2",
                        "title": "Capstone Design & Documentation Guide",
                        "type": "Presentation",
                        "summary": "Structuring research questions, datasets, experimentation logs, and ethical reflections.",
                        "url": "https://www.ibo.org/",
                    },
                ],
            },
        },
        "news": [
            {
                "id": "news-1",
                "title": "Updated CBSE CS & IP Practical & Lab Checklists Released",
                "date": "2026-11-15",
                "category": "CBSE",
                "summary": "New practice worksheets for Python file handling, SQL queries, Pandas DataFrames, and Matplotlib plots are now live in Academics.",
                "details": "Students preparing for Grade 11 and Grade 12 practical assessments can now access updated sample lab prompts, coding guidelines, and viva preparation notes directly inside the CBSE Computer Science and Informatics Practices sections.",
                "link": "https://cbseacademic.nic.in/",
            },
            {
                "id": "news-2",
                "title": "IB CRS AI Year 1 & Year 2 Capstone Rubrics & Case Studies",
                "date": "2026-11-10",
                "category": "IB CRS AI",
                "summary": "Explore new ethical AI case studies and project planning templates under Year 1 and Year 2 units.",
                "details": "We have added structured guides covering problem framing, dataset fairness audits, model evaluation metrics, and research documentation for IB CRS AI learners.",
                "link": "https://www.ibo.org/",
            },
            {
                "id": "news-3",
                "title": "Welcome to the ShineBright Centralised Learning Hub",
                "date": "2026-11-01",
                "category": "Announcement",
                "summary": "Learn, explore, create, and shine with curated CBSE and IB CRS AI resources in one place.",
                "details": "ShineBright brings together structured academic materials, searchable study guides, announcements, and a direct contact channel for students and educators.",
                "link": "",
            },
        ],
        "messages": [],
    }


def load_data() -> dict:
    if DATA_FILE.exists():
        try:
            with open(DATA_FILE, "r", encoding="utf-8") as f:
                loaded = json.load(f)
            defaults = get_default_data()
            for key in defaults:
                if key not in loaded:
                    loaded[key] = defaults[key]
            return loaded
        except Exception:
            pass
    return get_default_data()


def save_data(data: dict) -> None:
    try:
        with open(DATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except OSError:
        # Fallback safely if deployed on a read-only filesystem
        pass


if "sb_data" not in st.session_state:
    st.session_state.sb_data = load_data()

if "admin_mode" not in st.session_state:
    st.session_state.admin_mode = False

if "selected_cbse" not in st.session_state:
    st.session_state.selected_cbse = {"subject": None, "grade": None}

if "selected_ib" not in st.session_state:
    st.session_state.selected_ib = {"year": None, "unit": None}

if "search_query" not in st.session_state:
    st.session_state.search_query = ""


def persist_and_sync():
    save_data(st.session_state.sb_data)


# ---------------------------------------------------------------------------
# Dialogs for Viewing Details & Editing News
# ---------------------------------------------------------------------------
@st.dialog("Announcement Details")
def show_news_dialog(item: dict):
    st.caption(f"Published: {item['date']}  •  Category: {item['category']}")
    st.markdown(f"### {item['title']}")
    st.write(item["details"])
    if item.get("link"):
        st.link_button("Open Related Resource", item["link"], icon=":material/open_in_new:")


@st.dialog("Edit News Update")
def edit_news_dialog(index: int):
    news_list = st.session_state.sb_data["news"]
    item = news_list[index]
    with st.form(f"edit_news_form_{index}"):
        title = st.text_input("Title", value=item["title"])
        date_val = st.text_input("Date (YYYY-MM-DD)", value=item["date"])
        category = st.selectbox(
            "Category",
            ["CBSE", "IB CRS AI", "Announcement"],
            index=["CBSE", "IB CRS AI", "Announcement"].index(item.get("category", "Announcement"))
            if item.get("category") in ["CBSE", "IB CRS AI", "Announcement"]
            else 2,
        )
        summary = st.text_area("Short Description", value=item["summary"], height=80)
        details = st.text_area("Full Announcement", value=item["details"], height=130)
        link = st.text_input("Resource Link (optional)", value=item.get("link", ""))
        submitted = st.form_submit_button("Save Changes", type="primary")
        if submitted:
            if not title.strip() or not summary.strip():
                st.error("Title and short description are required.")
            else:
                news_list[index] = {
                    **item,
                    "title": title.strip(),
                    "date": date_val.strip() or datetime.now().strftime("%Y-%m-%d"),
                    "category": category,
                    "summary": summary.strip(),
                    "details": details.strip() or summary.strip(),
                    "link": link.strip(),
                }
                persist_and_sync()
                st.toast("News item updated.")
                st.rerun()


# ---------------------------------------------------------------------------
# Shared Header & Search Helper
# ---------------------------------------------------------------------------
def render_brand_header():
    col_brand, col_search, col_admin = st.columns([4, 4, 2], vertical_alignment="center")
    with col_brand:
        st.markdown(
            """
            <div style="display:flex;align-items:center;gap:12px;">
                <div style="width:44px;height:44px;border-radius:12px;
                            background:linear-gradient(135deg,#1d4ed8,#0ea5e9);
                            display:flex;align-items:center;justify-content:center;
                            color:white;font-weight:800;font-size:20px;">SB</div>
                <div>
                    <div style="font-size:1.45rem;font-weight:800;line-height:1.15;">ShineBright</div>
                    <div style="font-size:0.85rem;opacity:0.78;font-weight:600;letter-spacing:0.3px;">
                        Learn | Explore | Create | Shine
                    </div>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )
    with col_search:
        query = st.text_input(
            "Search academic resources",
            value=st.session_state.search_query,
            placeholder="Search CBSE, IB CRS AI, Python, SQL, Pandas, AI...",
            label_visibility="collapsed",
            key="global_search_input",
        )
        st.session_state.search_query = query
    with col_admin:
        admin_toggle = st.toggle(
            "Admin Mode",
            value=st.session_state.admin_mode,
            help="Enable to add, edit, or delete units, resources, and news updates.",
        )
        if admin_toggle != st.session_state.admin_mode:
            st.session_state.admin_mode = admin_toggle
            st.rerun()


def search_resources(query: str) -> list[dict]:
    q = query.strip().lower()
    if not q:
        return []
    matches = []

    # Search CBSE
    for subject, grades in st.session_state.sb_data["cbse"].items():
        for grade, items in grades.items():
            for res in items:
                haystack = f"CBSE {subject} {grade} {res['title']} {res['type']} {res['summary']}".lower()
                if q in haystack:
                    matches.append(
                        {
                            "programme": "CBSE",
                            "path": f"{subject} → {grade}",
                            **res,
                        }
                    )

    # Search IB CRS AI
    for year, units in st.session_state.sb_data["ib_crs_ai"].items():
        for unit, items in units.items():
            for res in items:
                haystack = f"IB CRS AI {year} {unit} {res['title']} {res['type']} {res['summary']}".lower()
                if q in haystack:
                    matches.append(
                        {
                            "programme": "IB CRS AI",
                            "path": f"{year} → {unit}",
                            **res,
                        }
                    )
    return matches


def render_resource_card(res: dict, context_label: str = "", on_delete=None):
    with st.container(border=True):
        top_l, top_r = st.columns([4, 1], vertical_alignment="center")
        with top_l:
            st.markdown(f"**{res['title']}**")
            if context_label:
                st.caption(context_label)
        with top_r:
            st.badge(res["type"])
        st.write(res["summary"])
        btn_col1, btn_col2 = st.columns([2, 1])
        with btn_col1:
            if res.get("url"):
                st.link_button("Open Resource", res["url"], icon=":material/open_in_new:")
        if st.session_state.admin_mode and on_delete is not None:
            with btn_col2:
                if st.button("Delete", key=f"del_{res['id']}_{context_label}", icon=":material/delete:"):
                    on_delete()
                    st.rerun()


# ---------------------------------------------------------------------------
# Page 1: Home
# ---------------------------------------------------------------------------
def page_home():
    render_brand_header()
    st.space("small")

    # Show instant search results if user typed in the search bar
    if st.session_state.search_query.strip():
        results = search_resources(st.session_state.search_query)
        with st.container(border=True):
            st.subheader(f"Search Results for '{st.session_state.search_query.strip()}'")
            if not results:
                st.info("No matching academic resources found. Try another keyword.")
            else:
                st.caption(f"Found {len(results)} matching resource(s)")
                for r in results:
                    render_resource_card(r, context_label=f"{r['programme']} • {r['path']}")
        st.space("small")

    # Hero Banner
    with st.container(border=True):
        hero_left, hero_right = st.columns([3, 2], vertical_alignment="center")
        with hero_left:
            st.badge("Centralised Academic Platform")
            st.title("Welcome to ShineBright")
            st.markdown(
                """
                **Learn | Explore | Create | Shine** — A clear, student-friendly learning hub bringing together
                structured academic resources, subject notes, hands-on labs, and timely announcements for
                **CBSE** and **IB CRS AI** learners.
                """
            )
            q1, q2, q3 = st.columns(3)
            with q1:
                st.page_link(page_academics, label="Explore Academics", icon=":material/school:", use_container_width=True)
            with q2:
                st.page_link(page_news, label="Latest News", icon=":material/newspaper:", use_container_width=True)
            with q3:
                st.page_link(page_contact, label="Contact Us", icon=":material/mail:", use_container_width=True)

        with hero_right:
            st.image(
                "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80",
                caption="Structured study materials & guided practice for students",
                use_container_width=True,
            )

    st.space("small")

    # Purpose & Vision
    st.subheader("Purpose & Vision")
    v1, v2, v3 = st.columns(3)
    with v1:
        with st.container(border=True):
            st.markdown("#### :material/hub: Centralised Access")
            st.write("All CBSE and IB CRS AI study guides, notes, and updates organised in one simple place.")
    with v2:
        with st.container(border=True):
            st.markdown("#### :material/psychology: Conceptual Clarity")
            st.write("Step-by-step explanations, practical coding labs, and unit-wise materials built for steady progress.")
    with v3:
        with st.container(border=True):
            st.markdown("#### :material/edit_note: Easy Content Updates")
            st.write("Administrators can add or update units, learning resources, and news without touching source code.")

    st.space("small")

    # Programmes Overview
    st.subheader("Academic Programmes")
    p1, p2 = st.columns(2)
    with p1:
        with st.container(border=True):
            st.markdown("### CBSE Programme")
            st.write("Focused curriculum resources for **Computer Science (CS)** and **Informatics Practices (IP)** across **Grade 11** and **Grade 12**.")
            st.markdown("- **Computer Science (CS):** Python programming, data structures, SQL & networking\n- **Informatics Practices (IP):** Pandas, Matplotlib visualisation, SQL & digital society")
            st.page_link(page_academics, label="Go to CBSE Resources", icon=":material/arrow_forward:")

    with p2:
        with st.container(border=True):
            st.markdown("### IB CRS AI Programme")
            st.write("Unit-based learning materials for **Year 1** and **Year 2**, designed to grow flexibly as new units and resources are added.")
            st.markdown("- **Year 1:** AI foundations, problem framing, data literacy & supervised learning\n- **Year 2:** Neural networks, deep learning concepts, AI ethics & research")
            st.page_link(page_academics, label="Go to IB CRS AI Resources", icon=":material/arrow_forward:")

    st.space("small")

    # Latest News Preview
    st.subheader("Latest News & Updates")
    news_items = st.session_state.sb_data["news"][:3]
    n_cols = st.columns(len(news_items) if news_items else 1)
    for idx, item in enumerate(news_items):
        with n_cols[idx]:
            with st.container(border=True):
                st.caption(f"{item['date']} • {item['category']}")
                st.markdown(f"**{item['title']}**")
                st.write(item["summary"])
                if st.button("Read More", key=f"home_news_{item['id']}"):
                    show_news_dialog(item)


# ---------------------------------------------------------------------------
# Page 2: Academics (Two-Panel Tree + Content Display + Admin Controls)
# ---------------------------------------------------------------------------
def page_academics():
    render_brand_header()
    st.space("small")
    st.title("Academics")
    st.caption("Select CBSE or IB CRS AI in the left navigation panel to browse grades, units, and study resources.")

    # Search filter inside Academics
    active_query = st.session_state.search_query.strip().lower()

    left_panel, right_panel = st.columns([1.15, 2.35], gap="large")

    # ---------------- LEFT PANEL: Navigation Tree ----------------
    with left_panel:
        with st.container(border=True):
            st.markdown("### :material/account_tree: Academic Navigation")

            # --- CBSE Tree ---
            with st.expander("CBSE", expanded=True):
                if st.button("CBSE Overview (CS & IP)", key="tree_cbse_overview", use_container_width=True):
                    st.session_state.selected_cbse = {"subject": None, "grade": None}
                    st.session_state.selected_ib = {"year": None, "unit": None}
                    st.rerun()

                for subject, grades in st.session_state.sb_data["cbse"].items():
                    with st.expander(subject, expanded=(st.session_state.selected_cbse["subject"] == subject)):
                        for grade in grades.keys():
                            is_selected = (
                                st.session_state.selected_cbse["subject"] == subject
                                and st.session_state.selected_cbse["grade"] == grade
                            )
                            if st.button(
                                f"{'▸ ' if is_selected else ''}{grade}",
                                key=f"tree_cbse_{subject}_{grade}",
                                use_container_width=True,
                                type="primary" if is_selected else "secondary",
                            ):
                                st.session_state.selected_cbse = {"subject": subject, "grade": grade}
                                st.session_state.selected_ib = {"year": None, "unit": None}
                                st.rerun()

            # --- IB CRS AI Tree ---
            with st.expander("IB CRS AI", expanded=True):
                for year, units in st.session_state.sb_data["ib_crs_ai"].items():
                    with st.expander(year, expanded=(st.session_state.selected_ib["year"] == year)):
                        for unit in units.keys():
                            is_unit_selected = (
                                st.session_state.selected_ib["year"] == year
                                and st.session_state.selected_ib["unit"] == unit
                            )
                            if st.button(
                                f"{'▸ ' if is_unit_selected else ''}{unit}",
                                key=f"tree_ib_{year}_{unit}",
                                use_container_width=True,
                                type="primary" if is_unit_selected else "secondary",
                            ):
                                st.session_state.selected_ib = {"year": year, "unit": unit}
                                st.session_state.selected_cbse = {"subject": None, "grade": None}
                                st.rerun()

    # ---------------- RIGHT PANEL: Content Display ----------------
    with right_panel:
        sel_ib = st.session_state.selected_ib
        sel_cbse = st.session_state.selected_cbse

        # Case 1: IB CRS AI Unit Selected
        if sel_ib["year"] and sel_ib["unit"]:
            year = sel_ib["year"]
            unit = sel_ib["unit"]
            st.subheader(f"IB CRS AI — {year}")
            st.markdown(f"#### {unit}")

            resources = st.session_state.sb_data["ib_crs_ai"][year][unit]
            if active_query:
                resources = [
                    r for r in resources
                    if active_query in f"{r['title']} {r['type']} {r['summary']}".lower()
                ]

            if not resources:
                st.info("No learning materials available yet for this unit.")
            else:
                for idx, res in enumerate(resources):
                    def make_del_ib(y=year, u=unit, r_id=res["id"]):
                        def _del():
                            st.session_state.sb_data["ib_crs_ai"][y][u] = [
                                item for item in st.session_state.sb_data["ib_crs_ai"][y][u]
                                if item["id"] != r_id
                            ]
                            persist_and_sync()
                        return _del

                    render_resource_card(res, context_label=f"IB CRS AI • {year} • {unit}", on_delete=make_del_ib())

            if st.session_state.admin_mode:
                with st.expander("Add Learning Material to This Unit", expanded=False):
                    with st.form(f"add_ib_res_{year}_{unit}"):
                        title = st.text_input("Resource Title")
                        rtype = st.selectbox("Resource Type", ["PDF Notes", "Presentation", "Code Lab", "Video Lecture"])
                        summary = st.text_area("Description / Summary")
                        url = st.text_input("Resource URL (optional)")
                        if st.form_submit_button("Add Resource", type="primary"):
                            if title.strip() and summary.strip():
                                new_res = {
                                    "id": f"ib-{datetime.now().timestamp()}",
                                    "title": title.strip(),
                                    "type": rtype,
                                    "summary": summary.strip(),
                                    "url": url.strip() or "https://www.ibo.org/",
                                }
                                st.session_state.sb_data["ib_crs_ai"][year][unit].append(new_res)
                                persist_and_sync()
                                st.success("Resource added.")
                                st.rerun()
                            else:
                                st.error("Please enter both a title and a description.")

        # Case 2: CBSE Subject & Grade Selected
        elif sel_cbse["subject"] and sel_cbse["grade"]:
            subject = sel_cbse["subject"]
            grade = sel_cbse["grade"]
            st.subheader(f"CBSE — {subject} ({grade})")

            resources = st.session_state.sb_data["cbse"][subject][grade]
            if active_query:
                resources = [
                    r for r in resources
                    if active_query in f"{r['title']} {r['type']} {r['summary']}".lower()
                ]

            if not resources:
                st.info("No study materials found for this grade.")
            else:
                for res in resources:
                    def make_del_cbse(s=subject, g=grade, r_id=res["id"]):
                        def _del():
                            st.session_state.sb_data["cbse"][s][g] = [
                                item for item in st.session_state.sb_data["cbse"][s][g]
                                if item["id"] != r_id
                            ]
                            persist_and_sync()
                        return _del

                    render_resource_card(res, context_label=f"CBSE • {subject} • {grade}", on_delete=make_del_cbse())

            if st.session_state.admin_mode:
                with st.expander(f"Add Resource to {subject} — {grade}", expanded=False):
                    with st.form(f"add_cbse_res_{subject}_{grade}"):
                        title = st.text_input("Resource Title")
                        rtype = st.selectbox("Resource Type", ["PDF Notes", "Presentation", "Code Lab", "Video Lecture"])
                        summary = st.text_area("Description / Summary")
                        url = st.text_input("Resource URL (optional)")
                        if st.form_submit_button("Add Resource", type="primary"):
                            if title.strip() and summary.strip():
                                new_res = {
                                    "id": f"cbse-{datetime.now().timestamp()}",
                                    "title": title.strip(),
                                    "type": rtype,
                                    "summary": summary.strip(),
                                    "url": url.strip() or "https://cbseacademic.nic.in/",
                                }
                                st.session_state.sb_data["cbse"][subject][grade].append(new_res)
                                persist_and_sync()
                                st.success("Resource added.")
                                st.rerun()
                            else:
                                st.error("Please enter both a title and a description.")

        # Case 3: Default CBSE Cards View (CS & IP with Grade 11 & Grade 12 cards + images)
        else:
            st.subheader("CBSE — Computer Science & Informatics Practices")
            st.write("Choose a subject and grade card below to view study materials.")

            subject_images = {
                "Computer Science (CS)": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80",
                "Informatics Practices (IP)": "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=800&q=80",
            }

            for subject, grades in st.session_state.sb_data["cbse"].items():
                with st.container(border=True):
                    s_img, s_info = st.columns([1, 2.5], vertical_alignment="center")
                    with s_img:
                        st.image(
                            subject_images.get(subject, "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=800&q=80"),
                            caption=subject,
                            use_container_width=True,
                        )
                    with s_info:
                        st.markdown(f"### {subject}")
                        st.write("Select a grade to open syllabus notes, coding examples, and practice resources.")
                        g_cols = st.columns(len(grades))
                        for idx, grade in enumerate(grades.keys()):
                            with g_cols[idx]:
                                if st.button(
                                    f"{grade} ({len(grades[grade])} items)",
                                    key=f"card_btn_{subject}_{grade}",
                                    use_container_width=True,
                                    type="primary",
                                ):
                                    st.session_state.selected_cbse = {"subject": subject, "grade": grade}
                                    st.session_state.selected_ib = {"year": None, "unit": None}
                                    st.rerun()

        # Admin: Add New IB CRS AI Unit dynamically
        if st.session_state.admin_mode:
            st.space("small")
            with st.container(border=True):
                st.markdown("### :material/admin_panel_settings: Admin: Add New IB CRS AI Unit")
                with st.form("add_ib_unit_form"):
                    u_col1, u_col2 = st.columns([1, 2])
                    with u_col1:
                        target_year = st.selectbox("Select Year", list(st.session_state.sb_data["ib_crs_ai"].keys()))
                    with u_col2:
                        unit_name = st.text_input("New Unit Title", placeholder="e.g., Unit 3: Natural Language Processing")
                    if st.form_submit_button("Create Unit", type="primary"):
                        clean_unit = unit_name.strip()
                        if not clean_unit:
                            st.error("Please enter a unit name.")
                        elif clean_unit in st.session_state.sb_data["ib_crs_ai"][target_year]:
                            st.warning("This unit already exists in the selected year.")
                        else:
                            st.session_state.sb_data["ib_crs_ai"][target_year][clean_unit] = []
                            persist_and_sync()
                            st.success(f"Added '{clean_unit}' to {target_year}.")
                            st.rerun()


# ---------------------------------------------------------------------------
# Page 3: News
# ---------------------------------------------------------------------------
def page_news():
    render_brand_header()
    st.space("small")
    st.title("News & Announcements")
    st.caption("Latest updates for CBSE and IB CRS AI students and educators, ordered newest first.")

    # Admin: Add News Item
    if st.session_state.admin_mode:
        with st.expander("Add New Announcement", expanded=False):
            with st.form("add_news_form"):
                title = st.text_input("Announcement Title")
                c1, c2 = st.columns(2)
                with c1:
                    date_str = st.text_input("Date (YYYY-MM-DD)", value=datetime.now().strftime("%Y-%m-%d"))
                with c2:
                    category = st.selectbox("Category", ["CBSE", "IB CRS AI", "Announcement"])
                summary = st.text_area("Short Description", height=80)
                details = st.text_area("Full Details", height=120)
                link = st.text_input("Optional Resource Link (https://...)")
                if st.form_submit_button("Publish News", type="primary"):
                    if not title.strip() or not summary.strip():
                        st.error("Title and short description are required.")
                    else:
                        new_item = {
                            "id": f"news-{datetime.now().timestamp()}",
                            "title": title.strip(),
                            "date": date_str.strip() or datetime.now().strftime("%Y-%m-%d"),
                            "category": category,
                            "summary": summary.strip(),
                            "details": details.strip() or summary.strip(),
                            "link": link.strip(),
                        }
                        st.session_state.sb_data["news"].insert(0, new_item)
                        persist_and_sync()
                        st.success("Announcement published.")
                        st.rerun()

    # Sort latest first
    sorted_news = sorted(
        enumerate(st.session_state.sb_data["news"]),
        key=lambda pair: pair[1].get("date", ""),
        reverse=True,
    )

    if not sorted_news:
        st.info("No announcements available yet.")
    else:
        for orig_idx, item in sorted_news:
            with st.container(border=True):
                h_left, h_right = st.columns([4, 1], vertical_alignment="center")
                with h_left:
                    st.markdown(f"### {item['title']}")
                    st.caption(f"Date: {item['date']}  •  Category: {item.get('category', 'Announcement')}")
                with h_right:
                    st.badge(item.get("category", "Update"))

                st.write(item["summary"])

                act_cols = st.columns([1.4, 1.4, 1, 1, 3])
                with act_cols[0]:
                    if st.button("Read Full Update", key=f"read_news_{item['id']}", icon=":material/article:"):
                        show_news_dialog(item)
                if item.get("link"):
                    with act_cols[1]:
                        st.link_button("Resource Link", item["link"], icon=":material/open_in_new:")
                if st.session_state.admin_mode:
                    with act_cols[2]:
                        if st.button("Edit", key=f"edit_news_{item['id']}", icon=":material/edit:"):
                            edit_news_dialog(orig_idx)
                    with act_cols[3]:
                        if st.button("Delete", key=f"del_news_{item['id']}", icon=":material/delete:"):
                            st.session_state.sb_data["news"].pop(orig_idx)
                            persist_and_sync()
                            st.rerun()


# ---------------------------------------------------------------------------
# Page 4: Contact Us
# ---------------------------------------------------------------------------
def is_valid_email(email: str) -> bool:
    return bool(re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", email.strip()))


def page_contact():
    render_brand_header()
    st.space("small")
    st.title("Contact Us")
    st.caption("Have a question about CBSE or IB CRS AI resources? Send a message to the ShineBright administrator.")

    admin_email = st.secrets.get("ADMIN_EMAIL", "admin@shinebright.edu.example")

    form_col, info_col = st.columns([2, 1.15], gap="large")

    with form_col:
        with st.container(border=True):
            st.subheader("Send a Query")
            with st.form("contact_form", clear_on_submit=True):
                name = st.text_input("Name *")
                email = st.text_input("Email ID *")
                subject = st.text_input("Subject *")
                message = st.text_area("Query / Message *", height=140)

                # Spam protection: honeypot + simple arithmetic check
                honeypot = st.text_input("Leave this field blank", value="", key="hp_field", label_visibility="collapsed")
                c_q, c_a = st.columns([2, 1], vertical_alignment="center")
                with c_q:
                    st.markdown("**Spam Check:** What is **4 + 5**? *")
                with c_a:
                    captcha_ans = st.text_input("Answer", label_visibility="collapsed", placeholder="Enter sum")

                submitted = st.form_submit_button("Submit Query", type="primary")

                if submitted:
                    if honeypot.strip():
                        st.error("Submission blocked by spam filter.")
                    elif not name.strip() or not email.strip() or not subject.strip() or not message.strip():
                        st.error("Please fill in all mandatory fields (Name, Email ID, Subject, and Query / Message).")
                    elif not is_valid_email(email):
                        st.error("Please enter a valid email address (e.g., student@example.com).")
                    elif captcha_ans.strip() != "9":
                        st.error("Incorrect spam check answer. Please enter 9.")
                    else:
                        entry = {
                            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M"),
                            "name": name.strip(),
                            "email": email.strip(),
                            "subject": subject.strip(),
                            "message": message.strip(),
                        }
                        st.session_state.sb_data["messages"].insert(0, entry)
                        persist_and_sync()

                        mailto_url = (
                            f"mailto:{urllib.parse.quote(admin_email)}"
                            f"?subject={urllib.parse.quote('[ShineBright] ' + subject.strip())}"
                            f"&body={urllib.parse.quote(f'From: {name.strip()} ({email.strip()})\n\n{message.strip()}')}"
                        )
                        st.success("Thank you! Your query has been recorded and prepared for the administrator.")
                        st.link_button("Compose in Default Email Client", mailto_url, icon=":material/mail:")

    with info_col:
        with st.container(border=True):
            st.subheader("Administrator & Support")
            st.markdown(f"**Contact Person:** ShineBright Academic Desk")
            st.markdown(f"**Official Email:** `{admin_email}`")
            st.markdown("**Support Hours:** Mon – Sat, 9:00 AM – 6:00 PM")
            st.markdown("**Social Links:** YouTube • LinkedIn • GitHub")

    # Admin Inbox View
    if st.session_state.admin_mode:
        st.space("small")
        with st.container(border=True):
            st.subheader(f"Submitted Queries ({len(st.session_state.sb_data['messages'])})")
            if not st.session_state.sb_data["messages"]:
                st.caption("No queries submitted yet in this session.")
            else:
                for msg in st.session_state.sb_data["messages"]:
                    st.markdown(f"**{msg['subject']}** — from *{msg['name']}* (`{msg['email']}`) on `{msg['timestamp']}`")
                    st.write(msg["message"])
                    st.divider()


# ---------------------------------------------------------------------------
# Navigation & Persistent Footer
# ---------------------------------------------------------------------------
page_home_obj = st.Page(page_home, title="Home", icon=":material/home:", default=True)
page_academics = st.Page(page_academics, title="Academics", icon=":material/school:")
page_news = st.Page(page_news, title="News", icon=":material/newspaper:")
page_contact = st.Page(page_contact, title="Contact Us", icon=":material/mail:")

nav = st.navigation(
    {
        "ShineBright": [page_home_obj, page_academics, page_news, page_contact]
    },
    position="top",
)
current_page = nav.run()

# Consistent Footer Across All Pages
st.space("large")
st.divider()
f1, f2, f3, f4 = st.columns([2, 1, 1, 1.5])
with f1:
    st.markdown("### ShineBright")
    st.caption("Learn | Explore | Create | Shine — Centralised academic platform for CBSE and IB CRS AI.")
    st.caption("© 2026 ShineBright. All rights reserved.")
with f2:
    st.markdown("**Quick Links**")
    st.page_link(page_home_obj, label="Home")
    st.page_link(page_academics, label="Academics")
    st.page_link(page_news, label="News")
    st.page_link(page_contact, label="Contact Us")
with f3:
    st.markdown("**Academic Links**")
    st.page_link(page_academics, label="CBSE (CS & IP)")
    st.page_link(page_academics, label="IB CRS AI")
with f4:
    st.markdown("**Policies & Contact**")
    st.caption(f"Email: {st.secrets.get('ADMIN_EMAIL', 'admin@shinebright.edu.example')}")
    st.caption("Privacy Policy • Terms and Conditions")
